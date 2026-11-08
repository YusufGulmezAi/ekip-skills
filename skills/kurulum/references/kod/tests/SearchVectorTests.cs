using System.Text.Json;
using App.Common;
using Xunit;

namespace App.Common.Tests;

/// <summary>
/// Ortak vektör dosyası (<c>search-vectors.json</c>): C# <see cref="TextNormalizer"/>, SQL <c>search_normalize_v1</c>
/// ve istemci (JS/Dart) normalleştiricisi aynı dosyayı okur; biri değişirse hepsi aynı testle sınanır.
/// Dosya test projesinde <c>CopyToOutputDirectory</c> ile çıktıya kopyalanır.
/// </summary>
public class SearchVectorTests
{
    /// <summary>Vektör dosyasındaki tek satır.</summary>
    public sealed record SearchVector(string Input, string Expected);

    /// <summary>Vektör dosyasını okur; dosya yoksa test kırmızı olur (sessizce sıfır vaka çalışmaz).</summary>
    public static IReadOnlyList<SearchVector> Load()
    {
        var path = Path.Combine(AppContext.BaseDirectory, "search-vectors.json");
        var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
        var vectors = JsonSerializer.Deserialize<List<SearchVector>>(File.ReadAllText(path), options);
        Assert.NotNull(vectors);
        Assert.NotEmpty(vectors);
        return vectors;
    }

    [Fact]
    public void ForSearch_MatchesEveryVector()
    {
        var failures = Load()
            .Where(v => TextNormalizer.ForSearch(v.Input) != v.Expected)
            .Select(v => $"{Escape(v.Input)} → {Escape(TextNormalizer.ForSearch(v.Input))} (beklenen {Escape(v.Expected)})")
            .ToList();
        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures));
    }

    /// <summary>Görünmeyen karakterleri hata mesajında <c>U+XXXX</c> olarak gösterir.</summary>
    public static string Escape(string text) => string.Concat(text.EnumerateRunes()
        .Select(r => r.Value is < 0x20 or > 0x7E ? $"U+{r.Value:X4} " : r.ToString()));
}
