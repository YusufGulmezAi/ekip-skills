namespace KonutYonetim.Yapi;

/// <summary>Sitedeki blok (yapi).</summary>
public sealed class Blok
{
    public Guid Id { get; set; }
    public string PublicId { get; set; } = "";
    public string Ad { get; set; } = "";
    public string AdArama { get; set; } = "";
    public int KatSayisi { get; set; }
}
