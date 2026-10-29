using App.Common;
using Xunit;

namespace App.Common.Tests;

/// <summary>Türkçe arama normalleştirmesinin sınır durumları.</summary>
public class TextNormalizerTests
{
    [Theory]
    [InlineData("isparta", "isparta")]
    [InlineData("Isparta", "isparta")]
    [InlineData("ISPARTA", "isparta")]
    [InlineData("ısparta", "isparta")]
    [InlineData("Işık", "isik")]
    [InlineData("IŞIK", "isik")]
    [InlineData("ışık", "isik")]
    [InlineData("isik", "isik")]
    [InlineData("İzmir", "izmir")]
    [InlineData("IZMIR", "izmir")]
    [InlineData("izmir", "izmir")]
    [InlineData("Çağrı Öğüt", "cagri ogut")]
    [InlineData("ŞİŞLİ", "sisli")]
    [InlineData("  çok   boşluklu\tmetin ", "cok bosluklu metin")]
    [InlineData("Kâğıt", "kagit")]
    [InlineData("i\u0307stanbul", "istanbul")] // ayrışık İ (i + birleşik nokta)
    [InlineData("Café Ünlü", "cafe unlu")]
    public void ForSearch_TurkishVariants_ProduceSameForm(string input, string expected) =>
        Assert.Equal(expected, TextNormalizer.ForSearch(input));

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("   ")]
    public void ForSearch_Empty_ReturnsEmpty(string? input) => Assert.Equal(string.Empty, TextNormalizer.ForSearch(input));

    [Fact]
    public void ContainsPattern_EscapesLikeWildcards() =>
        Assert.Equal("%\\%50\\_indirim\\\\%", TextNormalizer.ContainsPattern("%50_İndirim\\"));
}
