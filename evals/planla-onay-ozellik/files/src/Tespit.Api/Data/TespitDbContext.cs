using Microsoft.EntityFrameworkCore;
using Tespit.Api.Domain;

namespace Tespit.Api.Data;

public sealed class TespitDbContext(DbContextOptions<TespitDbContext> options, ITenantContext tenant)
    : DbContext(options)
{
    public DbSet<Blok> Bloklar => Set<Blok>();
    public DbSet<Daire> Daireler => Set<Daire>();
    public DbSet<Kusur> Kusurlar => Set<Kusur>();

    protected override void OnModelCreating(ModelBuilder b)
    {
        // Her firma (tenant) yalnızca kendi verisini görür.
        b.Entity<Blok>().HasQueryFilter(x => x.FirmaId == tenant.FirmaId);
        b.Entity<Daire>().HasQueryFilter(x => x.Blok.FirmaId == tenant.FirmaId);
        b.Entity<Kusur>().HasQueryFilter(x => x.Daire.Blok.FirmaId == tenant.FirmaId);
    }
}

public interface ITenantContext
{
    Guid FirmaId { get; }
    Guid KullaniciId { get; }
    string Rol { get; } // "EmlakOfisi" | "Musavir" | "Muteahhit" | "Taseron"
}
