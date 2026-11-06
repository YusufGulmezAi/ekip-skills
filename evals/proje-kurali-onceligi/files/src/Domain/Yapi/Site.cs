namespace KonutYonetim.Yapi;

/// <summary>Yonetilen site.</summary>
public sealed class Site
{
    public Guid Id { get; set; }
    public string PublicId { get; set; } = "";
    public string Ad { get; set; } = "";
    public string AdArama { get; set; } = "";
}
