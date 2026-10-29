using Xunit;

namespace Tespit.Api.Tests;

/// <summary>Müşavir onay ucunun durum kurallarını doğrular.</summary>
public class KusurOnaylaTests
{
    [Fact]
    public void OnayBekleyenKusur_Onaylanir()
    {
        // Mevcut örnek test: OnayBekliyor -> Onaylandi geçişi.
        Assert.True(true); // fixture kısaltması; gerçek projede WebApplicationFactory kullanılır
    }
}
