namespace Tespit.Api.Domain;

public sealed class Blok
{
    public Guid Id { get; set; }
    public Guid FirmaId { get; set; }
    public string Ad { get; set; } = "";
    public List<Daire> Daireler { get; set; } = [];
}

public sealed class Daire
{
    public Guid Id { get; set; }
    public Guid BlokId { get; set; }
    public Blok Blok { get; set; } = null!;
    public string No { get; set; } = "";
    public int Kat { get; set; }
    public string Tip { get; set; } = ""; // "2+1", "3+1"
    public List<Kusur> Kusurlar { get; set; } = [];
}

public enum KusurDurumu { Acik, OnayBekliyor, Onaylandi, GeriGonderildi, Duzeltildi, Kapandi }
public enum Onem { Hafif, Orta, Agir }
public enum GeriGondermeGerekcesi { EksikFotograf, YanlisKriter, OnemHatali, MahalAtlanmis }

public sealed class Kusur
{
    public Guid Id { get; set; }
    public Guid DaireId { get; set; }
    public Daire Daire { get; set; } = null!;
    public string Mahal { get; set; } = "";   // "Banyo", "Mutfak" ...
    public string Kriter { get; set; } = "";
    public Onem Onem { get; set; }
    public KusurDurumu Durum { get; set; }
    public Guid OlusturanKullaniciId { get; set; }
    public GeriGondermeGerekcesi? GeriGondermeGerekcesi { get; set; }
    public string? Not { get; set; }
}
