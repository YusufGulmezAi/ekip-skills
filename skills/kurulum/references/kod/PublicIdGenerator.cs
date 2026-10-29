using System.Security.Cryptography;

namespace App.Common;

/// <summary>
/// URL ve rotalarda kullanılan genel kimlik: 10 küçük ASCII harf (<c>[a-z]{10}</c>, Türkçe harf yok).
/// Kriptografik rastgele üretilir; tahmin ve numaralandırma engellenir. Benzersizliği tablo indeksi garanti eder.
/// </summary>
public static class PublicIdGenerator
{
    /// <summary>Kimlik uzunluğu.</summary>
    public const int Length = 10;

    /// <summary>Veri tabanı <c>CHECK</c> kısıtı ve doğrulama için düzenli ifade.</summary>
    public const string Pattern = "^[a-z]{10}$";

    private const string Alphabet = "abcdefghijklmnopqrstuvwxyz";

    /// <summary>Yeni bir genel kimlik üretir.</summary>
    public static string New() => string.Create(Length, 0, static (span, _) =>
    {
        for (var i = 0; i < span.Length; i++)
        {
            span[i] = Alphabet[RandomNumberGenerator.GetInt32(Alphabet.Length)];
        }
    });

    /// <summary>Değer biçim olarak geçerli bir genel kimlik mi (veri tabanına sormadan).</summary>
    public static bool IsValid(string? value)
    {
        if (value is not { Length: Length })
        {
            return false;
        }

        foreach (var ch in value)
        {
            if (ch is < 'a' or > 'z')
            {
                return false;
            }
        }

        return true;
    }
}
