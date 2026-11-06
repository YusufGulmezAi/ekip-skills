using System.Text;

namespace App.Common;

/// <summary>
/// Türkçe metni arama için tek biçime indirger: Türkçe kurala göre küçük harf (I→ı, İ→i; ı/i ve ç/ş/ğ/ö/ü ayrı harf olarak
/// kalır), şapka sadeleşir (â→a, î→i, û→u), boşluk sadeleşir. "isparta" ISPARTA'yı bulmaz, "ısparta" bulur; "IZMIR" İzmir'i bulmaz.
/// Kayıttaki <c>&lt;Alan&gt;Search</c> sütunu ve arama terimi aynı fonksiyondan geçer.
/// Kültüre ve ICU'ya bağlı değildir: ICU'suz konteynerde (InvariantGlobalization) de aynı sonucu verir.
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

        var builder = new StringBuilder(text.Length);
        var pendingSpace = false;
        foreach (var ch in text.Trim())
        {
            if (char.IsWhiteSpace(ch))
            {
                pendingSpace = true;
                continue;
            }

            if (ch == '\u0307' && builder.Length > 0 && builder[^1] == 'ı')
            {
                builder[^1] = 'i'; // ayrışık İ: "I" + birleşik nokta
                continue;
            }

            var mapped = Fold(ch);
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

    /// <summary>LIKE desenine konacak terimdeki <c>\</c>, <c>%</c>, <c>_</c> karakterlerini kaçırır (kaçış karakteri <c>\</c>).</summary>
    public static string EscapeLike(string normalized) =>
        normalized.Replace("\\", "\\\\", StringComparison.Ordinal)
            .Replace("%", "\\%", StringComparison.Ordinal)
            .Replace("_", "\\_", StringComparison.Ordinal);

    /// <summary>"İçerir" araması için hazır desen: <c>%terim%</c>.</summary>
    public static string ContainsPattern(string? term) => $"%{EscapeLike(ForSearch(term))}%";

    /// <summary>Tek karakteri Türkçe kurala göre küçültür; atlanacak birleşik işaret için <c>'\0'</c> döner.</summary>
    private static char Fold(char ch) => ch switch
    {
        'I' => 'ı',
        'İ' => 'i',
        'Â' or 'â' => 'a',
        'Î' or 'î' => 'i',
        'Û' or 'û' => 'u',
        '\u0302' or '\u0307' => '\0', // ayrışık şapka ve nokta ("i̇" içindeki nokta İ'den gelir)
        _ => char.ToLowerInvariant(ch),
    };
}
