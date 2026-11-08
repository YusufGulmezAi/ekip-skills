using App.Common;
using Xunit;

namespace App.Common.Tests;

/// <summary>Türkçe arama normalleştirmesi: ı↔I ve i↔İ ayrı harf çiftleri, şapka sadeleşir.</summary>
public class TextNormalizerTests
{
    [Theory]
    [InlineData("isparta", "isparta")]
    [InlineData("İsparta", "isparta")]
    [InlineData("İSPARTA", "isparta")]
    [InlineData("ısparta", "ısparta")]
    [InlineData("Isparta", "ısparta")]
    [InlineData("ISPARTA", "ısparta")]
    [InlineData("İzmir", "izmir")]
    [InlineData("İZMİR", "izmir")]
    [InlineData("IZMIR", "ızmır")]
    [InlineData("Işık", "ışık")]
    [InlineData("IŞIK", "ışık")]
    [InlineData("Çağrı Öğüt", "çağrı öğüt")]
    [InlineData("ŞİŞLİ", "şişli")]
    [InlineData("Kâzım", "kazım")]
    [InlineData("KÂZIM", "kazım")]
    [InlineData("Kâğıt", "kağıt")]
    [InlineData("Îmar Ûmit", "imar umit")]
    [InlineData("i\u0307stanbul", "istanbul")] // ayrışık İ (i + birleşik nokta)
    [InlineData("I\u0307zmir", "izmir")] // ayrışık İ (I + birleşik nokta)
    [InlineData("  çok   boşluklu\tmetin ", "çok boşluklu metin")]
    [InlineData("\U00010400", "\U00010428")] // temel düzlem dışı (Deseret): PostgreSQL küçültür, char döngüsü küçültmez
    [InlineData("\U0001E900", "\U0001E922")] // temel düzlem dışı (Adlam)
    public void ForSearch_ProducesTurkishLowerForm(string input, string expected) =>
        Assert.Equal(expected, TextNormalizer.ForSearch(input));

    /// <summary>Kullanıcının arama tablosu (Yusuf, 06.11.2026): terim kayıtta geçiyor mu.</summary>
    [Theory]
    [InlineData("isparta", "isparta", true)]
    [InlineData("isparta", "İsparta", true)]
    [InlineData("isparta", "İSPARTA", true)]
    [InlineData("isparta", "ISPARTA", false)]
    [InlineData("isparta", "Isparta", false)]
    [InlineData("ısparta", "ısparta", true)]
    [InlineData("ısparta", "Isparta", true)]
    [InlineData("ısparta", "ISPARTA", true)]
    [InlineData("ısparta", "isparta", false)]
    [InlineData("ısparta", "İSPARTA", false)]
    [InlineData("izmir", "İzmir", true)]
    [InlineData("izmir", "İZMİR", true)]
    [InlineData("izmir", "IZMIR", false)]
    [InlineData("IZMIR", "İzmir", false)]
    [InlineData("IZMIR", "ızmır", true)]
    [InlineData("cagri", "Çağrı", false)]
    [InlineData("çağrı", "ÇAĞRI", true)]
    [InlineData("kazım", "Kâzım", true)]
    [InlineData("KAZIM", "Kâzım", true)]
    public void SearchTable_MatchesTurkishRules(string term, string record, bool expected) =>
        Assert.Equal(expected, TextNormalizer.ForSearch(record).Contains(TextNormalizer.ForSearch(term), StringComparison.Ordinal));

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("   ")]
    public void ForSearch_Empty_ReturnsEmpty(string? input) => Assert.Equal(string.Empty, TextNormalizer.ForSearch(input));

    [Fact]
    public void ContainsPattern_EscapesLikeWildcards() =>
        Assert.Equal("%\\%50\\_indirim\\\\%", TextNormalizer.ContainsPattern("%50_İndirim\\"));
}
