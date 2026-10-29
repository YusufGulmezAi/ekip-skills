using Microsoft.EntityFrameworkCore;
using Tespit.Api.Data;

namespace Tespit.Api.Endpoints;

public sealed record BlokDto(Guid Id, string Ad, int DaireSayisi);

public static class BlokEndpoints
{
    public static void MapBlokEndpoints(this IEndpointRouteBuilder app)
    {
        var grup = app.MapGroup("/bloklar").RequireAuthorization().WithTags("Bloklar");

        grup.MapGet("/", async (TespitDbContext db, CancellationToken ct) =>
        {
            var liste = await db.Bloklar
                .AsNoTracking()
                .OrderBy(b => b.Ad)
                .Select(b => new BlokDto(b.Id, b.Ad, b.Daireler.Count))
                .ToListAsync(ct);
            return Results.Ok(liste);
        });

        grup.MapGet("/{id:guid}", async (Guid id, TespitDbContext db, CancellationToken ct) =>
        {
            var blok = await db.Bloklar
                .AsNoTracking()
                .Where(b => b.Id == id)
                .Select(b => new BlokDto(b.Id, b.Ad, b.Daireler.Count))
                .FirstOrDefaultAsync(ct);
            return blok is null ? Results.NotFound() : Results.Ok(blok);
        });
    }
}
