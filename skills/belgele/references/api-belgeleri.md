# API belgeleri: dış ve iç ayrı, örnekli, istenince Word/PDF ve Postman

Karar: Yusuf, 17–18.11.2026 (`docs/yapilacaklar.md` madde 15); fintech-core ilk uygulamasının geri bildirimiyle düzeltildi (18.11.2026). HTTP API sunan her projede geçerlidir (minimal API ya da controller). API'si olmayan projede (yalnız sunucuda üretilen sayfalar, ör. Blazor SSR) kurulmaz; dış API kararı verildiğinde (ADR) bu düzenle baştan kurulur. Belgenin bölümleri, dizinler ve açıklamalı örnek: `api-belge-yapisi.md`.

Öncelik sırası: (1) güvenlik açığı oluşmaz, (2) profesyonel yapı, gruplama, dizin, (3) açıklamalı örnek.

## İlkeler
1. **İki kitle, iki belge.** **Dış** (bankalar, müşteriler, üçüncü taraflar): dağıtılır; Word, PDF, Postman koleksiyonu ve dış OpenAPI yalnız bundan. **İç** (ekip istemcileri, işletim, yönetim): depoda ya da proje kitabında kalır.
2. **Kitle uç metadata'sıdır, etiket değil.** Her uçta `ApiAudience.External | Internal` metadata'sı; OpenAPI'ye `x-audience` olarak yansır. OpenAPI dışında bilerek tutulan uçlar (sağlık, imzalı dış kanal) da işaretlidir; kapsam testi uç listesini OpenAPI'den değil `EndpointDataSource`'tan gezer.
3. **Tanım koddan.** OpenAPI koddan üretilir (.NET 10 `Microsoft.AspNetCore.OpenApi`). Dış uçlar için **adlandırılmış ikinci belge** (`AddOpenApi("external")` + kitleye göre `ShouldInclude`); bayrakla açılan üretim kipi kullanılmaz, iç belge bayt bayt aynı kalır. Elle yazılmış dış sözleşme varsa tanım odur; alanlarının kaynağı keşifle bulunur (ana belge, yan belgeler, JSON blokları) ve testte yanıtla karşılaştırılır.
4. **Örnek testten, elle yazılmaz;** açıklaması yan dosyada (`api-belge-yapisi.md`). Bayatlayan örnek test kırmızısıdır.
5. **Kod adları İngilizce:** `x-audience`, `ApiExamples/<external|internal>/<operationId>/...`, `ApiAudience`; belge metni Türkçe.

## Güvenlik (zorunlu; atlanırsa iş bitmemiştir)
1. **Maske izin listesiyle:** örneğe yalnız izin listesindeki başlık ve alan yazılır; listede olmayan atılır. Değişken değerler sabitlenir ya da yer tutucu olur (`<guid>`, `<timestamp>`, `<correlationId>`, `<signature>`). Yasak listesi kullanılmaz: sonradan eklenen alanı sızdırır.
2. **Veri sentetik:** gerçek kişi, TCKN, IBAN, kart, adres yok; deterministik test verisi.
3. **Yayımlanan test anahtarı canlıda reddedilir** ve bunu bir bekçi testi kanıtlar (ör. üretim yapılandırması belgedeki anahtar kimliğini kabul etmez). Anahtar belgede "TEST" işaretlidir.
4. **Hata cevabı varlık sızdırmaz:** belgelenen her hata durumu için "bu cevap, yetkisi olmayana kaydın varlığını söylüyor mu?" sorusu cevaplanır (başkasının kaydı ile olmayan kayıt aynı cevabı alır).
5. **Dış paket içerik taraması:** üretilen PDF, DOCX, Postman koleksiyonu ve dış OpenAPI metne çevrilip sır, iç yol, iç başlık, iç ana makine adı ve `localhost` için taranır (gitleaks + proje kalıpları). Depo taraması yetmez; çıktı depoya girmez.
6. **Postman ve dış OpenAPI:** temel adres yer tutucu (`{{baseUrl}}`); anahtar değişkenleri boş ve `secret` tipli; istek öncesi betikte `console.log` yok (testle); dış OpenAPI `servers` yalnız yer tutucu.
7. **Dış kapakta commit kimliği yok;** sözleşme sürümü ve tarih yeter. Commit yalnız iç belgede.

## Kurulum (projede bir kez)
1. **Araç onayı:** belge zinciri araçları (`pandoc` GPL-2.0+ — çıktıyı bağlamaz ama araç zincirine girer; `docfx pdf` ilk koşuda Chromium indirir; `newman` geniş bağımlılık ağacı) lisans, indirilen ikili ve sürüm sabitlemesiyle listelenir; kullanıcı onaylar. Projenin ADR'si bir araç seçtiyse o önce gelir.
2. **`operationId` önce:** her uçta kalıcı `WithName("<Resource>_<Action>")`. Örnek klasörü, belge çapası ve Postman istek adı buna dayanır; minimal API `WithName` olmadan `operationId` üretmez.
3. **Envanter ve kitle:** `EndpointDataSource`'tan tüm uçlar; her birine kitle önerisi, kullanıcı onaylar. İşletim uçları iç.
4. **Tanım:** Türkçe `WithSummary`/`WithDescription`, `Produces<T>`, `ProducesProblem`; `securitySchemes` document transformer'la; iç ve dış belge ayrı adla üretilir, commit edilir, sapma testiyle korunur.
5. **Örnek yakalama:** test `HttpClient`'ına `DelegatingHandler`; izin listesiyle maskeli istek/yanıt `ApiExamples/<external|internal>/<operationId>/<status>-<short-name>.json`. Proje `docs/`'u insana ayırdıysa klasör test projesinde. Sapma testi; bilinçli değişiklikte ortam değişkeniyle (ör. `UPDATE_API_EXAMPLES=1`) yenilenir.
6. **Kapsam testi (CI kapısı):** `EndpointDataSource`'taki her uçta kitle, `operationId`, Türkçe özet, ≥ 1 başarı ve ≥ 1 hata örneği, açıklama dosyası; dış belgede iç uç yok, iç belgede dış uç yok. Hata üretmeyen uçlar (canlılık, sürüm) hata örneği kuralına **adıyla** istisnadır; istisna listesi testte, sessiz atlama yok.
7. **Belge üretimi ve dışa aktarma:** `api-belge-yapisi.md`'deki bölüm şablonuyla; Word `pandoc`, PDF HTML + Chromium (ya da ADR'nin aracı); CI'da elle tetiklenen iş ya da `yayin` adımı. Kanıt: Türkçe harfler doğru, iç uç yok, içerik taraması temiz.
8. **Postman (birincil) ve dış OpenAPI 3 (ikincil):** Postman Collection v2.1 + ortam dosyası (Güvenlik 6); özel kimlik doğrulama istek öncesi betikte; her istekte durum + şema testi. CI koleksiyonu Newman ile test ortamına karşı koşturur. OpenAPI 3.1 Postman'a aktarılamazsa 3.0 kopyası. Başka biçim yalnız bir okuyucu isterse.

## Süreçteki yeri
- **planla:** uç nokta ekleyen/değiştiren görevin `Belge:` satırı "API belgesi (dış|iç) + örnek ve açıklama".
- **uygula:** yeni uç `operationId` + kitle + özet + açıklamalı başarı ve hata örneği + dizin satırlarıyla biter; kapsam ve dizin testleri kırmızıysa bitmemiştir.
- **incele:** işaretsiz/özetsiz/örneksiz uç, dizinde olmayan hata kodu ya da alan, yasak listesiyle maske **Önemli**; dış pakete sızan iç uç ya da iç bilgi, örnekte gerçek veri ya da sır, varlık sızdıran hata cevabı, canlıda geçerli test anahtarı, dış uçta sürüm artışsız kırıcı değişiklik **Kritik**.
- **yayin:** dış belge değiştiyse Word, PDF, Postman koleksiyonu + ortam dosyası ve dış OpenAPI üretilir, içerik taramasından geçer, sürüme eklenir.
