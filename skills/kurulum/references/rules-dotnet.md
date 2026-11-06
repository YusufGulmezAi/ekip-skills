# `.claude/rules/dotnet.md` şablonu (≤ 60 satır)

```markdown
---
paths: ["**/*.cs", "**/*.csproj", "**/*.sln", "**/*.slnx"]
---
# .NET kuralları

## Dil ve açıklama
- Adlandırma <İngilizce + sözlük | Türkçe alan tipleri>. İngilizce: tür, üye, dosya, tablo ve kolon adları İngilizce, alan terimi eşlemesi `docs/sozluk.md` (Kusur → `Defect`). Türkçe alan tipleri: hukuki/alan terimleri Türkçe (`BagimsizBolum`, `ArsaPayi`), altyapı tipleri İngilizce (`IUrlAddressable`); veri tabanı nesneleri <snake_case dil>.
- Her public tür ve üyede Türkçe XML doc: `/// <summary>Müşavirin kusuru onaylayıp müteahhide iletmesi.</summary>`. `<param>`/`<returns>` yalnızca açıklama gerektiriyorsa. Bu yorumlar API başvurusunu ve eğitim dokümanlarını besler; boş veya İngilizce `<summary>` bulgu sayılır.
- Kullanıcıya dönen hiçbir metin kodda düz string değil (bkz. Yerelleştirme).

## Yerelleştirme (çoklu dil)
- Diller `.resx` ile: nötr `Messages.resx` varsayılan dili (tr) taşır, yanında `Messages.en.resx`, <diğer> (yalnız `.tr.resx` olursa nötr yedek boş kalır, anahtar adı görünür); `RequestLocalization` ara katmanı `Accept-Language` okur, desteklenen kültürler tek listede (`SupportedCultures`).
- Anahtarlar `static class MessageKeys` içinde sabit (`MessageKeys.DefectAssigned`); erişim boş çapa sınıfı `public sealed class Messages;` üzerinden `IStringLocalizer<Messages>` ile (static sınıf generic tip argümanı olamaz, CS0718). `.resx` yolu çapa sınıfının ad alanını izler (`Localization/Messages` → `Resources/Localization/Messages.resx`). Parametreli mesaj: `L[MessageKeys.DefectAssigned, defectNo, contractorName]` → `"{0} numaralı kusur {1} firmasına atandı"`; parametre sırası her dilde aynı, yorumda açıklanır.
- API hata yanıtı `ProblemDetails` + `code` (anahtar) + `params`; metin `Accept-Language`'e göre doldurulur. İstemci kodu `code`+`params` ile kendi dilinde yeniden üretebilir (mobil çevrimdışı). Anahtar listesi `docs/mesajlar.md` sözleşmesinde; yeni anahtar sözleşme değişikliği sayılır.
- Tarih, sayı ve para biçimi kültürden (`CultureInfo`), veri UTC ve ham sayı olarak saklanır; enum görünen adları da `.resx`'ten.

## Eşleme (AutoMapper yasak)
- AutoMapper, Mapster, Mapperly vb. kullanılmaz. Her varlık için `static class <Entity>Mapper` ve uzantı metotları: `defect.ToDto()`, `request.ToEntity()`, `defect.ApplyUpdate(request)`.
- Dosya başına bir eşleyici: `Mapping/DefectMapper.cs`; her eşleyici metodun testi var (`DefectMapperTests`).
- Eşleyicide iş kuralı yok; yalnızca alan aktarımı ve biçimlendirme.
- Varlık ve DTO kurulumu eşleyicide: uç noktada `new Entity { ... }` ya da `new XxxDto(...)` yok — rapor ve sorgu çıktıları dahil. Sunucuda türeyen değerler (zaman, yazar, numara) `ToEntity(...)` parametresi; EF sorgu projeksiyonu gerekiyorsa eşleyicide `Expression<Func<TEntity, TDto>>` olarak durur.

## Dosya boyutu ve bölme
- Dosya başına bir tür; sınıf ≤ 200, metot ≤ 30 satır, parametre ≤ 5 — **test dosyaları dahil** (büyüyen test sınıfı senaryoya göre bölünür). Aşınca davranışı yeni türe çıkar.
- Uç noktalar kaynak başına `Endpoints/<Resource>Endpoints.cs`; 8+ uç noktada alt kaynağa böl.
- DTO'lar `sealed record`, `Contracts/<Resource>/` altında dosya başına bir record. Migration'lar elle düzenlenmez.

## Düzen
- Solution: <Clean | Vertical Slice>; `src/<Project>/`, `tests/<Project>.UnitTests/`, `tests/<Project>.IntegrationTests/`, `tests/<Project>.SecurityTests/`.
- Katmanlar / dilimler: <Domain, Application, Infrastructure, Api | Features/<Area>/>. Modüller birbirine yalnız sözleşme katmanı (`Contracts`) üzerinden erişir.
- Bu sınırlar mimari testle zorlanır (<NetArchTest | ArchUnitNET>): katman yönü, modül sınırı, `IgnoreQueryFilters` izin listesi. Listeye satır eklemek güvenlik kararıdır; testin kaynak kümesinin boş olmadığı ayrıca doğrulanır.

## Web (Blazor varsa)
- Render modu <statik SSR (varsayılan) | Interactive Server>; sayfalar ham kontrol yazmaz, ortak bileşen kütüphanesini kullanır; bileşen onayı canlı katalog sayfasında. Bilinen tuzaklar: `ekip-skills` `incele/references/blazor-ssr.md`.

## Veri ve güvenlik
- Çok kiracılı: her kiracılı varlıkta global query filter; `IgnoreQueryFilters()` yalnızca karar kaydı ve mimari testteki izin listesiyle.
- Aşağı doğru navigation koleksiyonu yok (`Site.Blocks`); alt kayıt üst kayda referans verir, ilişki şemada (gerekirse bileşik) yabancı anahtarla. İstisna: ebeveyniyle birlikte yüklenen sınırlı küme, gerekçesi yazılır.
- `AsNoTracking` okuma sorgularında; döngüde sorgu yok; `CancellationToken` her async çağrıda; `DateTime.Now` yerine `TimeProvider`/UTC. Türkçe arama, saat dilimi, PublicId ve sürüm: `veri.md`.
- Her uç nokta yetkili grupta; rol kontrolü uç noktada. `FromSqlRaw` ile interpolasyon yok. `HttpClient` istek başına değil (`IHttpClientFactory`).
- Yapılandırma ortam değişkeni / user secrets; `appsettings.*.json` içinde sır yok (bkz. `altyapi.md`).
- Dosya yükleme: boyut sınırı + içerik türü sihirli baytla; görsellerden **EXIF/GPS silinir** (konum sızıntısı); erişim imzalı süreli URL ile; depolama <MinIO | dosya + yedek>.
- Giriş ve parola sıfırlama uç noktalarında rate limiting (`AddRateLimiter`, 429).

## Çevrimdışı istemci destekleri (çevrimdışı modül varsa)
- `Idempotency-Key`: aynı anahtar ikinci kez gelirse yeni kayıt açılmaz, ilk yanıt döner; anahtarlar <24 saat> saklanır. Kayıt kimlikleri istemciden gelir (UUID v7), sunucu çakışanı reddeder.
- Gözlem verisi **ekle-yalnız** (güncelleme yok, her kayıt ayrı; denetim izi bedava); düzenlenen varlıkta concurrency token (`rowversion`) + 409.
- Eski duruma dayalı istek sessizce uygulanmaz ve sessizce düşürülmez: 409 + `ProblemDetails` `code`+`params`.
- Çift zaman: `CreatedAtLocal` (cihaz, bilgi amaçlı) + `ReceivedAt` (sunucu, UTC); sıralama ve rapor sunucu saatiyle.

## Gözlemlenebilirlik
- Yapısal log Serilog ile; mesaj şablonu, interpolasyon yok; logda PII ve sır yok (kişi adı değil id).
- Her istekte correlation ID: `X-Correlation-Id` başlığı (yoksa üret), yanıtla geri döner, log scope'una girer; mobil hata ekranındaki kod budur.
- `/health` (liveness) ve `/health/ready` (DB bağlantısı) uç noktaları; Docker `HEALTHCHECK` bunları çağırır.

## Test (üç katman)
- **Birim** (`UnitTests`): <xUnit | MSTest>; eşleyiciler, iş kuralları, hesaplar; dış bağımlılık yok. Ad: `Method_State_Expected`. Testte `Task.Delay`/`Thread.Sleep` yok; zaman ve sıra `FakeTimeProvider` (ya da elle sahte `TimeProvider`) ile.
- **Entegrasyon** (`IntegrationTests`): `WebApplicationFactory` + <Testcontainers PostgreSQL | SQLite>; her uç nokta için başarılı yol + yetkisiz + yanlış durum.
- **Güvenlik** (`SecurityTests`): her kiracılı uç nokta için "başka firmanın verisi 404", rolsüz erişim 403, kimliksiz 401; girdi doğrulama (çok uzun, boş, enjeksiyon kalıbı) 400. Plan: `guvenlik-testi` skill'i. CI'da `dotnet list package --vulnerable` ve ZAP baseline taraması.
- **Seed**: `tools/Seed/` Bogus ile **deterministik** (sabit tohum) sentetik veri; entegrasyon testleri ve Demo aynı üreteci kullanır. Üretimden veri kopyalanmaz.
```
