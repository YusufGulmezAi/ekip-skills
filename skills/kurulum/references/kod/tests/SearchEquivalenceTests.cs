using App.Common;
using Npgsql;
using Testcontainers.PostgreSql;
using Xunit;

namespace App.Common.Tests;

/// <summary>
/// C# <see cref="TextNormalizer"/> ile SQL <c>search_normalize_v1</c> eşdeğerliği (entegrasyon, gerçek PostgreSQL 17+).
/// Üretilmiş arama sütunu SQL'de, arama terimi ve bellek içi arama C#'ta normalleşir; ikisi ayrışırsa kayıt bulunmaz.
/// SQL dosyası (<c>search_normalize_v1.sql</c>) ve vektör dosyası test çıktısına kopyalanır; migration aynı SQL'i çalıştırır.
/// </summary>
public sealed class SearchEquivalenceTests : IAsyncLifetime
{
    private readonly PostgreSqlContainer _db = new PostgreSqlBuilder().WithImage("postgres:17-alpine").Build();

    public async Task InitializeAsync()
    {
        await _db.StartAsync();
        var sql = await File.ReadAllTextAsync(Path.Combine(AppContext.BaseDirectory, "search_normalize_v1.sql"));
        await ExecuteAsync(sql);
    }

    public Task DisposeAsync() => _db.DisposeAsync().AsTask();

    [Fact]
    public async Task Sql_MatchesEveryVector()
    {
        var vectors = SearchVectorTests.Load();
        var sqlResults = await NormalizeInSqlAsync(vectors.Select(v => v.Input).ToArray());
        var failures = vectors.Zip(sqlResults)
            .Where(p => p.Second != p.First.Expected)
            .Select(p => $"{SearchVectorTests.Escape(p.First.Input)} → SQL {SearchVectorTests.Escape(p.Second)}")
            .ToList();
        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures));
    }

    /// <summary>Tüm Unicode kod noktaları (U+0000 ve vekil çiftler hariç), tek başına ve "I" ile birlikte.</summary>
    [Fact]
    public async Task Sql_MatchesCSharp_ForEveryCodePoint()
    {
        var inputs = Enumerable.Range(1, 0x10FFFF)
            .Where(cp => cp is < 0xD800 or > 0xDFFF)
            .SelectMany(cp => new[] { char.ConvertFromUtf32(cp), "I" + char.ConvertFromUtf32(cp) })
            .ToArray();
        var failures = new List<string>();
        foreach (var batch in inputs.Chunk(50_000))
        {
            var sqlResults = await NormalizeInSqlAsync(batch);
            failures.AddRange(batch.Zip(sqlResults)
                .Where(p => p.Second != TextNormalizer.ForSearch(p.First))
                .Select(p => $"{SearchVectorTests.Escape(p.First)}: C# {SearchVectorTests.Escape(TextNormalizer.ForSearch(p.First))}, SQL {SearchVectorTests.Escape(p.Second)}"));
        }

        Assert.True(failures.Count == 0, $"{failures.Count} fark:{Environment.NewLine}{string.Join(Environment.NewLine, failures.Take(50))}");
    }

    /// <summary>Üretilmiş sütun tohum, INSERT ve toplu güncellemede de dolar; bayatlık sorgusu sıfır döner.</summary>
    [Fact]
    public async Task GeneratedColumn_IsNeverStale()
    {
        await ExecuteAsync("""
            CREATE TABLE city (id int PRIMARY KEY, name text NOT NULL,
              name_search text GENERATED ALWAYS AS (search_normalize_v1(name)) STORED);
            INSERT INTO city (id, name) VALUES (1, 'İSPARTA'), (2, 'Kâzım');
            UPDATE city SET name = 'IZMIR' WHERE id = 2;
            """);
        Assert.Equal(0L, await ScalarAsync("SELECT count(*) FROM city WHERE name_search IS DISTINCT FROM search_normalize_v1(name)"));
        Assert.Equal(1L, await ScalarAsync($"SELECT count(*) FROM city WHERE name_search LIKE '{TextNormalizer.ContainsPattern("ızmır")}'"));
    }

    private async Task<string[]> NormalizeInSqlAsync(string[] inputs)
    {
        await using var connection = new NpgsqlConnection(_db.GetConnectionString());
        await connection.OpenAsync();
        await using var command = new NpgsqlCommand(
            "SELECT coalesce(search_normalize_v1(t.v), '') FROM unnest(@inputs) WITH ORDINALITY AS t(v, n) ORDER BY t.n", connection);
        command.Parameters.AddWithValue("inputs", inputs);
        var results = new List<string>(inputs.Length);
        await using var reader = await command.ExecuteReaderAsync();
        while (await reader.ReadAsync())
        {
            results.Add(reader.GetString(0));
        }

        return results.ToArray();
    }

    private async Task ExecuteAsync(string sql)
    {
        await using var connection = new NpgsqlConnection(_db.GetConnectionString());
        await connection.OpenAsync();
        await using var command = new NpgsqlCommand(sql, connection);
        await command.ExecuteNonQueryAsync();
    }

    private async Task<object?> ScalarAsync(string sql)
    {
        await using var connection = new NpgsqlConnection(_db.GetConnectionString());
        await connection.OpenAsync();
        await using var command = new NpgsqlCommand(sql, connection);
        return await command.ExecuteScalarAsync();
    }
}
