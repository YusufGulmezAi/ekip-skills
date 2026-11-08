using System.Text;

namespace App.Common;

/// <summary>
/// Türkçe metni arama için tek biçime indirger: Türkçe kurala göre küçük harf (I→ı, İ→i; ı/i ve ç/ş/ğ/ö/ü ayrı harf olarak
/// kalır), şapka sadeleşir (â→a, î→i, û→u), boşluk sadeleşir. "isparta" ISPARTA'yı bulmaz, "ısparta" bulur; "IZMIR" İzmir'i bulmaz.
/// SQL karşılığı <c>search_normalize_v1</c> (üretilmiş arama sütunu) aynı adımları aynı sırayla uygular; eşdeğerlik testle
/// (ortak vektör dosyası + tüm kod noktaları) korunur. Küçültme <see cref="Rune"/> düzeyindedir: temel düzlem dışı harfler de
/// (U+10400 → U+10428) PostgreSQL'deki gibi küçülür. Kültüre ve ICU'ya bağlı değildir (InvariantGlobalization'da da aynı sonuç).
/// </summary>
public static class TextNormalizer
{
    /// <summary>Arama sütununa yazılacak ya da terim olarak kullanılacak biçimi üretir; boş girdi için boş metin.</summary>
    public static string ForSearch(string? text)
    {
        if (string.IsNullOrWhiteSpace(text))
        {
            return string.Empty;
        }

        var lowered = LowerTurkish(text).Replace("ı̇", "i", StringComparison.Ordinal); // ayrışık İ: "I" + birleşik nokta
        return SimplifyMarksAndSpaces(lowered);
    }

    /// <summary>LIKE desenine konacak terimdeki <c>\</c>, <c>%</c>, <c>_</c> karakterlerini kaçırır (kaçış karakteri <c>\</c>).</summary>
    public static string EscapeLike(string normalized) =>
        normalized.Replace("\\", "\\\\", StringComparison.Ordinal)
            .Replace("%", "\\%", StringComparison.Ordinal)
            .Replace("_", "\\_", StringComparison.Ordinal);

    /// <summary>"İçerir" araması için hazır desen: <c>%terim%</c>.</summary>
    public static string ContainsPattern(string? term) => $"%{EscapeLike(ForSearch(term))}%";

    /// <summary>Adım 1–2: I→ı, İ→i; kalan her harf Unicode basit küçültmeyle (SQL: <c>lower(... COLLATE pg_c_utf8)</c>).</summary>
    private static string LowerTurkish(string text)
    {
        var builder = new StringBuilder(text.Length);
        foreach (var rune in text.EnumerateRunes())
        {
            var lower = rune.Value switch
            {
                'I' => new Rune('ı'),
                'İ' => new Rune('i'),
                _ => Rune.ToLowerInvariant(rune),
            };
            builder.Append(lower.ToString());
        }

        return builder.ToString();
    }

    /// <summary>Adım 4–5: â î û sadeleşir, ayrışık şapka ve nokta silinir; boşluk dizisi tek boşluk, baş/son boşluk yok.</summary>
    private static string SimplifyMarksAndSpaces(string text)
    {
        var builder = new StringBuilder(text.Length);
        var pendingSpace = false;
        foreach (var ch in text)
        {
            if (char.IsWhiteSpace(ch))
            {
                pendingSpace = builder.Length > 0;
                continue;
            }

            var mapped = ch switch { 'â' => 'a', 'î' => 'i', 'û' => 'u', '̂' or '̇' => '\0', _ => ch };
            if (mapped == '\0')
            {
                continue;
            }

            if (pendingSpace)
            {
                builder.Append(' ');
                pendingSpace = false;
            }

            builder.Append(mapped);
        }

        return builder.ToString();
    }
}
