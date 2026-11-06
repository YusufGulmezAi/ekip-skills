namespace SiteYonetim.Siteler;

/// <summary>Yonetilen site (kiraci).</summary>
public sealed class Site
{
    public Guid Id { get; set; }
    public string PublicId { get; set; } = "";
    public string Name { get; set; } = "";
    public string NameSearch { get; set; } = "";
}
