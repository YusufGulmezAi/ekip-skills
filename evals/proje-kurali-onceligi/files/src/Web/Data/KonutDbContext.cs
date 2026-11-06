using KonutYonetim.Yapi;
using Microsoft.EntityFrameworkCore;

namespace KonutYonetim.Web.Data;

/// <summary>Uygulamanin veri baglami.</summary>
public sealed class KonutDbContext(DbContextOptions<KonutDbContext> options) : DbContext(options)
{
    public DbSet<Site> Siteler => Set<Site>();
    public DbSet<Blok> Bloklar => Set<Blok>();
}
