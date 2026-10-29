using System.Globalization;
using App.Common;
using Xunit;

namespace App.Common.Tests;

/// <summary>Yerel gün aralığının UTC'ye çevrilmesi; sınır anları ve yaz saati geçişleri.</summary>
public class LocalDateRangeTests
{
    private static readonly TimeZoneInfo Istanbul = LocalDateRange.Zone(null);

    [Fact]
    public void ToUtc_SingleIstanbulDay_IsHalfOpenUtcRange()
    {
        var range = LocalDateRange.ToUtc(new DateOnly(2026, 10, 29), new DateOnly(2026, 10, 29), Istanbul);

        Assert.Equal(new DateTimeOffset(2026, 10, 28, 21, 0, 0, TimeSpan.Zero), range.Start);
        Assert.Equal(new DateTimeOffset(2026, 10, 29, 21, 0, 0, TimeSpan.Zero), range.End);
    }

    [Theory]
    [InlineData("2026-10-28T21:00:00Z", true)]   // yerel 29.10 00:00
    [InlineData("2026-10-28T21:30:00Z", true)]   // yerel 29.10 00:30 — UTC'de önceki gün
    [InlineData("2026-10-29T20:59:59Z", true)]   // yerel 29.10 23:59:59
    [InlineData("2026-10-29T21:00:00Z", false)]  // yerel 30.10 00:00
    [InlineData("2026-10-28T20:59:59Z", false)]  // yerel 28.10 23:59:59
    public void Contains_BoundaryInstants(string instant, bool expected)
    {
        var range = LocalDateRange.ToUtc(new DateOnly(2026, 10, 29), new DateOnly(2026, 10, 29), Istanbul);

        Assert.Equal(expected, range.Contains(DateTimeOffset.Parse(instant, CultureInfo.InvariantCulture)));
    }

    [Fact]
    public void ToUtc_MonthRange_CoversWholeLocalMonth()
    {
        var range = LocalDateRange.ToUtc(new DateOnly(2026, 12, 1), new DateOnly(2026, 12, 31), Istanbul);

        Assert.Equal(new DateTimeOffset(2026, 11, 30, 21, 0, 0, TimeSpan.Zero), range.Start);
        Assert.Equal(new DateTimeOffset(2026, 12, 31, 21, 0, 0, TimeSpan.Zero), range.End);
    }

    [Fact]
    public void ToUtc_EndBeforeStart_Throws() =>
        Assert.Throws<ArgumentException>(() => LocalDateRange.ToUtc(new DateOnly(2026, 10, 2), new DateOnly(2026, 10, 1), Istanbul));

    [Theory]
    [InlineData("2026-03-29", 23)] // Berlin ileri sarma günü
    [InlineData("2026-10-25", 25)] // Berlin geri sarma günü
    public void ToUtc_DstDay_HasRealLength(string day, int hours)
    {
        var date = DateOnly.Parse(day, CultureInfo.InvariantCulture);
        var range = LocalDateRange.ToUtc(date, date, LocalDateRange.Zone("Europe/Berlin"));

        Assert.Equal(TimeSpan.FromHours(hours), range.End - range.Start);
    }

    [Fact]
    public void LocalDate_EarlyMorningInstant_IsNextLocalDay() =>
        Assert.Equal(new DateOnly(2026, 10, 29),
            LocalDateRange.LocalDate(new DateTimeOffset(2026, 10, 28, 22, 15, 0, TimeSpan.Zero), Istanbul));
}
