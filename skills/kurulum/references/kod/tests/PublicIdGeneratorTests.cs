using App.Common;
using Xunit;

namespace App.Common.Tests;

/// <summary>Genel kimlik üretiminin biçim ve dağılım testleri.</summary>
public class PublicIdGeneratorTests
{
    [Fact]
    public void New_ProducesTenLowercaseAsciiLetters()
    {
        for (var i = 0; i < 1000; i++)
        {
            var id = PublicIdGenerator.New();
            Assert.Matches(PublicIdGenerator.Pattern, id);
            Assert.True(PublicIdGenerator.IsValid(id));
        }
    }

    [Fact]
    public void New_TenThousandIds_AreDistinct()
    {
        var ids = Enumerable.Range(0, 10_000).Select(_ => PublicIdGenerator.New()).ToHashSet(StringComparer.Ordinal);

        Assert.Equal(10_000, ids.Count);
    }

    [Theory]
    [InlineData("abcdefghij", true)]
    [InlineData("Abcdefghij", false)]
    [InlineData("abcdefghi", false)]
    [InlineData("abcdefghijk", false)]
    [InlineData("abcdefgh1j", false)]
    [InlineData("abcdefghış", false)]
    [InlineData("abcdefghi-", false)]
    [InlineData(null, false)]
    public void IsValid_ChecksFormat(string? value, bool expected) => Assert.Equal(expected, PublicIdGenerator.IsValid(value));
}
