namespace App.Common;

/// <summary>Yarı açık UTC aralığı: <c>Start</c> dahil, <c>End</c> hariç.</summary>
/// <param name="Start">Aralığın başlangıç anı (dahil).</param>
/// <param name="End">Aralığın bitiş anı (hariç).</param>
public readonly record struct UtcRange(DateTimeOffset Start, DateTimeOffset End)
{
    /// <summary>Anın aralıkta olup olmadığı.</summary>
    public bool Contains(DateTimeOffset instant) => instant >= Start && instant < End;
}

/// <summary>
/// Kullanıcının yerel takvim günlerini veri tabanı sorgusu için UTC aralığına çevirir.
/// Sorgu her zaman <c>&gt;= Start AND &lt; End</c>; <c>&lt;= 23:59:59</c> ya da <c>.Date</c> karşılaştırması kullanılmaz.
/// </summary>
public static class LocalDateRange
{
    /// <summary>Kiracının saat dilimi tanımlı değilse kullanılan IANA adı.</summary>
    public const string DefaultZoneId = "Europe/Istanbul";

    /// <summary>IANA adından saat dilimini bulur; boşsa varsayılanı döner.</summary>
    public static TimeZoneInfo Zone(string? ianaId) =>
        TimeZoneInfo.FindSystemTimeZoneById(string.IsNullOrWhiteSpace(ianaId) ? DefaultZoneId : ianaId);

    /// <summary><paramref name="from"/> gününün başından <paramref name="to"/> gününün sonuna kadar olan aralık.</summary>
    public static UtcRange ToUtc(DateOnly from, DateOnly to, TimeZoneInfo zone)
    {
        if (to < from)
        {
            throw new ArgumentException("Bitiş günü başlangıç gününden önce olamaz.", nameof(to));
        }

        return new UtcRange(StartOfDayUtc(from, zone), StartOfDayUtc(to.AddDays(1), zone));
    }

    /// <summary>Yerel günün ilk anı (UTC); yaz saati geçişinde gece yarısı yoksa ilk geçerli an.</summary>
    public static DateTimeOffset StartOfDayUtc(DateOnly day, TimeZoneInfo zone)
    {
        var local = day.ToDateTime(TimeOnly.MinValue, DateTimeKind.Unspecified);
        while (zone.IsInvalidTime(local))
        {
            local = local.AddMinutes(15);
        }

        var offset = zone.IsAmbiguousTime(local) ? zone.GetAmbiguousTimeOffsets(local).Max() : zone.GetUtcOffset(local);
        return new DateTimeOffset(local, offset).ToUniversalTime();
    }

    /// <summary>Bir anın kiracının saat dilimindeki takvim günü (gruplama ve gösterim için).</summary>
    public static DateOnly LocalDate(DateTimeOffset instant, TimeZoneInfo zone) =>
        DateOnly.FromDateTime(TimeZoneInfo.ConvertTime(instant, zone).DateTime);
}
