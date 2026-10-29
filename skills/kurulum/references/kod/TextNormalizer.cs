using System.Text;

namespace App.Common;

/// <summary>
/// Türkçe metni arama için tek biçime indirger: küçük harf, aksansız (ç→c, ğ→g, ı/İ/I→i, ö→o, ş→s, ü→u, â/î/û→a/i/u),
/// sadeleştirilmiş boşluk. Kayıttaki <c>&lt;Alan&gt;Search</c> sütunu ve arama terimi aynı fonksiyondan geçer.
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

    /// <summary>Tek karakteri katlar; atlanacak birleşik işaret için <c>'\0'</c> döner.</summary>
    private static char Fold(char ch) => ch switch
    {
        'I' or 'İ' or 'ı' or 'i' or 'Î' or 'î' or 'Í' or 'í' or 'Ì' or 'ì' or 'Ï' or 'ï' => 'i',
        'Ç' or 'ç' => 'c',
        'Ğ' or 'ğ' => 'g',
        'Ö' or 'ö' or 'Ó' or 'ó' or 'Ò' or 'ò' or 'Ô' or 'ô' => 'o',
        'Ş' or 'ş' => 's',
        'Ü' or 'ü' or 'Û' or 'û' or 'Ú' or 'ú' or 'Ù' or 'ù' => 'u',
        'Â' or 'â' or 'Á' or 'á' or 'À' or 'à' or 'Ä' or 'ä' => 'a',
        'É' or 'é' or 'È' or 'è' or 'Ê' or 'ê' or 'Ë' or 'ë' => 'e',
        >= '̀' and <= 'ͯ' => '\0', // birleşik aksan (ör. "i̇" içindeki nokta)
        _ => char.ToLowerInvariant(ch),
    };
}
