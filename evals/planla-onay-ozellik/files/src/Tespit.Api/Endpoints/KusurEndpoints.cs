using Microsoft.EntityFrameworkCore;
using Tespit.Api.Data;
using Tespit.Api.Domain;

namespace Tespit.Api.Endpoints;

public sealed record KusurDto(Guid Id, string DaireNo, string Mahal, string Kriter, Onem Onem, KusurDurumu Durum);
public sealed record GeriGonderIstegi(GeriGondermeGerekcesi Gerekce, string? Not);

public static class KusurEndpoints
{
    public static void MapKusurEndpoints(this IEndpointRouteBuilder app)
    {
        var grup = app.MapGroup("/kusurlar").RequireAuthorization().WithTags("Kusurlar");

        // Projedeki açık kusurlar. Müşavir ve müteahhit bu listeyle çalışır.
        grup.MapGet("/", async (Guid projeId, TespitDbContext db, ITenantContext kullanici, CancellationToken ct) =>
        {
            var liste = await db.Kusurlar
                .AsNoTracking()
                .Where(k => k.Durum != KusurDurumu.Kapandi)
                .Where(k => k.OlusturanKullaniciId == kullanici.KullaniciId)
                .OrderBy(k => k.Daire.No)
                .Select(k => new KusurDto(k.Id, k.Daire.No, k.Mahal, k.Kriter, k.Onem, k.Durum))
                .ToListAsync(ct);
            return Results.Ok(liste);
        });

        // Müşavir onayı: kusur müteahhide iletilir.
        grup.MapPost("/{id:guid}/onayla", async (Guid id, TespitDbContext db, CancellationToken ct) =>
        {
            var kusur = await db.Kusurlar.FirstOrDefaultAsync(k => k.Id == id, ct);
            if (kusur is null) return Results.NotFound();
            if (kusur.Durum != KusurDurumu.OnayBekliyor) return Results.Conflict("Kusur onay beklemiyor.");
            kusur.Durum = KusurDurumu.Onaylandi;
            await db.SaveChangesAsync(ct);
            return Results.NoContent();
        });

        // Müşavir geri gönderir: kusur gerekçeyle emlak ofisine döner.
        grup.MapPost("/{id:guid}/geri-gonder", async (Guid id, GeriGonderIstegi istek, TespitDbContext db, CancellationToken ct) =>
        {
            var kusur = await db.Kusurlar.FirstOrDefaultAsync(k => k.Id == id, ct);
            if (kusur is null) return Results.NotFound();
            if (kusur.Durum != KusurDurumu.OnayBekliyor) return Results.Conflict("Kusur onay beklemiyor.");
            kusur.Durum = KusurDurumu.GeriGonderildi;
            kusur.GeriGondermeGerekcesi = istek.Gerekce;
            kusur.Not = istek.Not;
            await db.SaveChangesAsync(ct);
            return Results.NoContent();
        });
    }
}
