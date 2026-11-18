# API belgeleri: dış ve iç ayrı, örnekli, istenince Word/PDF

Karar: Yusuf, 17–18.11.2026 (`docs/yapilacaklar.md` madde 15). HTTP API sunan her projede geçerlidir (minimal API ya da controller). API'si olmayan projede (yalnız sunucuda üretilen sayfalar, ör. Blazor SSR) kurulmaz; dış API kararı verildiğinde (ADR) bu düzenle baştan kurulur.

## İlkeler
1. **İki kitle, iki belge.**
   - **Dış belge:** bankalar, müşteriler, üçüncü taraflar. Dağıtılır; Word ve PDF yalnız bundan üretilir.
   - **İç belge:** ekip (web/mobil istemci, işletim, yönetim uçları). Depoda ya da proje kitabında kalır, dışarı gönderilmez.
2. **Her uç noktanın kitlesi açık.** Uç tanımında `dış` ya da `iç` işareti; OpenAPI'ye `x-kitle` uzantısı olarak yansır. İşaretsiz uç CI'da kırmızı. Dış belgeye iç uç, iç belgeye dış uç girmez.
3. **Tanım koddan.** OpenAPI derlemede koddan üretilir (.NET 10: `Microsoft.AspNetCore.OpenApi`); her işlemde Türkçe özet ve açıklama, istek/yanıt tipleri, hata yanıtları (`ProblemDetails` + `code` + `params`), kimlik doğrulama şeması. Elle yazılmış bir dış sözleşme varsa (ör. imzalı kanal) tanım odur; örnekleri yine testten gelir.
4. **Örnek testten, elle yazılmaz.** Uç noktayı HTTP ile çağıran entegrasyon testi istek ve yanıtı yakalar. Örnek, test geçtiği sürece doğrudur; bayatlarsa test kırmızı.
5. **Örnek verisi sentetik.** Gerçek kişi, TCKN, IBAN, kart, adres yok; deterministik test verisi. Anahtar ve imzalar test anahtarıyla, belgede "TEST" olarak işaretli.
6. **Çıktı depoya girmez.** Üretilen Markdown, Word ve PDF CI çıktısı (artifact) ya da yayın eki olur; her kopya kapakta ürün, kitle, sürüm, commit ve tarih taşır.

## Kurulum (ilk uygulama, projede bir kez)
1. **Envanter:** haritalanan tüm uçları listele (`Map*`, `[ApiController]`), her birine kitle öner; kullanıcı onaylar. İşletim uçları (`/health`, `/version`) iç.
2. **Kitle işareti:** küçük bir metadata tipi (`ApiAudience.External | Internal`) ve uç grubunda `.WithMetadata(...)` ya da `.WithTags("dış: ...")`; operation transformer bunu `x-kitle` yapar. Projede yerleşik etiket düzeni varsa ona uy.
3. **Tanım zenginleştirme:** her uçta `WithSummary`/`WithDescription` (Türkçe), `Produces<T>`, `ProducesProblem`; document transformer ile `securitySchemes` (çerez, bearer, imza başlığı neyse). OpenAPI dosyası commit edilir ve sapma testiyle korunur (proje zaten yapıyorsa ona bağlan).
4. **Örnek yakalama:** test `HttpClient`'ına `DelegatingHandler`; çıktı `docs/api/ornekler/<dis|ic>/<operationId>/<durum>-<kisa-ad>.json` (istek: yöntem, yol, gösterilecek başlıklar, gövde; yanıt: durum, başlıklar, gövde). Değişken değerler sabitlenir ya da maskelenir (`"<guid>"`, `"<zaman>"`, `"<correlationId>"`, `"<imza>"`); çerez ve gerçek belirteç yazılmaz. Proje `docs/`'u insana ayırdıysa (Claude düzenlemez) örnekler test klasöründe durur (ör. `tests/<Entegrasyon>/ApiOrnekleri/<dis|ic>/...`). Örnek dosyaları commit edilir; sapma testi canlı yakalamayı commit edilmiş dosyayla karşılaştırır, bilinçli değişiklikte bir ortam değişkeniyle (ör. `ORNEK_GUNCELLE=1`) yenilenir.
5. **Kapsam testi (CI kapısı):** OpenAPI'deki ve dış sözleşmedeki her işlem için kitle işareti, Türkçe özet, en az bir başarı ve bir hata örneği var; dış belgede iç işlem yok. Eksikte test adı ve eksik işlem listesiyle kırmızı.
6. **Belge üretimi:** betik OpenAPI + örnekler (+ dış sözleşme) → `dis.md` ve `ic.md` (üretilen, git dışı). Her işlem: amaç, yetki, istek, yanıtlar tablosu, örnekler, hata kodları; dış belgede ayrıca giriş/imza adımları ve sürüm değişiklikleri (`oasdiff changelog`). Projede belge zinciri varsa (DocFX, MkDocs) bu dosyalar onun bölümü olur; yoksa Markdown + yalnız Development/Test ortamında etkileşimli sayfa (Scalar).
7. **Dışa aktarma (istenince):** CI'da elle tetiklenen iş ya da `yayin` adımı.
   - Word: `pandoc dis.md -o api-dis-<sürüm>.docx --toc --reference-doc=<kurum-şablonu.docx>`.
   - PDF: Markdown → HTML → Chromium/Playwright ile PDF (LaTeX kurulumu gerekmez, Türkçe yazı tipi tarayıcıdan). Projenin ADR'si başka araç seçtiyse o önce gelir.
   - Kanıt: çıktıda ş ğ ı İ ö ü ç doğru, kapakta sürüm + commit + tarih, içinde iç uç yok (metinde `x-kitle: iç` işlemlerinin yolu aranır).

## Süreçteki yeri
- **planla:** uç nokta ekleyen ya da değiştiren görevin `Belge:` satırı "API belgesi (dış|iç) + örnek testi".
- **uygula:** yeni uç, kitle işareti + özet + başarı ve hata örneği testleriyle biter; kapsam testi kırmızıysa bitmemiştir.
- **incele:** işaretsiz/özetsiz/örneksiz uç, dış belgeye sızan iç uç, örnekte gerçek veri ya da sır **Önemli**; dış uçta kırıcı değişiklik sürüm artışı olmadan **Kritik**.
- **yayin:** dış belge değiştiyse Word/PDF üretilip sürüme eklenir.
