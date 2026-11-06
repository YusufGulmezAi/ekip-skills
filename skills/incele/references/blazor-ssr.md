# Blazor (statik SSR) kontrol listesi

Projede `.razor` dosyası varsa `dotnet.md` ile birlikte uygulanır. Maddeler gerçek projede yaşanmış hatalardan çıkarıldı; çoğu akış (HttpClient) testinde görünmez, tarayıcıda görünür.

**Kritik adayları**
- Form değerlerinin kültürü: statik SSR'da `[SupplyParameterFromForm]` modeli çerçevenin **sabit (invariant) kültürüyle** doldurulur; bileşenin `TryParseValueFromString`'i çalışmaz. `01.10.2026` → 10 Ocak, `1.250,50` → yanlış tutar. Tarih ve tutar alanı tr-TR biçimini kendisi çözen bir taban bileşenden ya da ara katmandan geçmeli; testler tarayıcının gönderdiği biçimi (`01.10.2026`, `1.250,50`) kullanmalı.
- Bileşende veri tabanı sorgusu: kardeş bileşenlerin `OnInitializedAsync`'i paralel çalışır; istek kapsamındaki `DbContext` paylaşılırsa "a second operation was started on this context" (500). Bileşen içi sorgu kendi kapsamında (`IServiceScopeFactory.CreateAsyncScope`).
- Yarım durum çizimi: sayfa `OnInitializedAsync`'in ilk gerçek beklemesinde o anki durumla çizilir; veri tabanına dokunan çocuk bileşenler erken doğar. Böyle çocuklar `_yuklendi` kapısının arkasında çizilir.
- Çift antiforgery: `EditForm` belirteci kendisi basar; içine ayrıca `<AntiforgeryToken />` konursa tarayıcıda 400 (akış testi görmez).

**Önemli adayları**
- Form adları: Blazor input adını `EditForm Model` ifadesinden üretir; bağlayıcı özellik adı ile ayrışırsa form **sessizce boş** bağlanır. Sıfırdan başlamayan dizi dizinleri (`Alanlar[13..20]`) bağlanmaz; görünen alanlar kesintisiz yeniden indekslenir.
- `[SupplyParameterFromForm]` `RenderFragment<T>` içinden bağlanmaz; `FormName` derleme zamanı sabiti ister.
- İç içe form olmaz; birden çok GET formu varsa diğer formların alanları gizli alanla taşınır.
- Gelişmiş gezinti (enhanced navigation) sunucunun basmadığı öznitelikleri siler: `dataset` bayrağıyla "kuruldu" işaretlenen JS dinleyicileri her gezintide yeniden eklenir (çift gönderim). Dinleyici kaydı `WeakSet` + olay delegasyonuyla; DOM kuran kurulum her `enhancedload`'da idempotent. Olaylar `Blazor.addEventListener` ile dinlenir, `document` ile değil.
- Sayfalar arası geçişte `<input>` öğesi korunur, öznitelikleri değişir: eski JS işleyicisi yeni alanda çalışır; işleyici öğeyi olay anında doğrulamalı.
- `data-enhance` taşımayan GET formu tam sayfa yükler; otomatik gönderimde odak kaybolur.
- Gönderim düğmesi `submit` anında `disabled` yapılırsa `name/value` gitmez (çok adımlı formda Geri/İleri kaybolur); kilit bir tur ertelenir, `event.submitter` kullanılır.
- Gizli paneldeki `required` alan tarayıcının formu **sessizce göndermemesine** yol açar; gönderimde gizli panelin zorunluluğu kaldırılır. Bunu yalnız gerçek tarayıcı testi (Playwright) yakalar.
- `IFormFile` iç içe modele bağlanır; form `enctype="multipart/form-data"`. Tarayıcı seçili dosyayı yeniden dolduramaz: doğrulama hatasında dosya önce kaydedilir, form kodunu taşır.
- HTML kodlayıcı: `AddWebEncoders(UnicodeRanges.All)` yoksa ş/ı `&#x15F;` olarak basılır.
- Etkileşimli ada (Interactive Server) devresi DI kapsamını ve "yetki her istekte çözülür" kuralını değiştirir; ada kullanımı karar kaydı ister.

**Test**
- Ekran işinde en az bir gerçek tarayıcı testi (Playwright, geçici veri tabanı); spec'ler aynı bootstrap hesabını paylaşıyorsa ayrı ayrı koşturulur.
- Uygulama testte 5000'li varsayılan dışında bir portta başlatılır, test sonunda yalnız kendi süreci durdurulur.
