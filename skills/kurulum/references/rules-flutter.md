# `.claude/rules/flutter.md` şablonu (≤ 60 satır)

```markdown
---
paths: ["**/*.dart", "**/pubspec.yaml", "**/analysis_options.yaml"]
---
# Flutter kuralları

## Dil ve açıklama
- Kod İngilizce: sınıf, metot, değişken, dosya adları (`defect_list_screen.dart`, `DefectListScreen`); alan terimi eşlemesi `docs/sozluk.md`.
- Her public sınıf ve üyede Türkçe dartdoc (`/// Taşerona atanan kusurları listeler.`); ekran sınıfının dartdoc'u kullanım bağlamını (kim, nerede) söyler. Bu yorumlar eğitim dokümanlarını besler.
- Kullanıcıya görünen hiçbir metin kodda düz string değil; `flutter_localizations` + `intl`, `lib/l10n/app_tr.arb` (varsayılan), `app_en.arb`, <diğer>; üretilen `AppLocalizations` ile `context.l10n.defectAssigned(defectNo, contractor)`.
- Parametreli ve çoğul mesajlar ARB yer tutucularıyla: `"defectAssigned": "{defectNo} numaralı kusur {contractor} firmasına atandı"`, `"openDefects": "{count, plural, =0{Açık kusur yok} one{1 açık kusur} other{{count} açık kusur}}"`; her anahtarda `@`-açıklama ve yer tutucu tipi.
- Sunucudan gelen `code`+`params` istemcide `AppLocalizations` ile yeniden üretilir; sunucu metni yalnızca yedek. Anahtarlar `docs/mesajlar.md` sözleşmesiyle backend ile ortak; eksik anahtar derleme hatası (`untranslated-messages-file`).

## Eşleme ve model
- Eşleme kütüphanesi yok. API modeli ↔ alan modeli dönüşümü `static` eşleyici sınıfında (`DefectMapper.fromDto`, `toRequest`), dosya başına bir eşleyici, testli.
- JSON: <json_serializable kod üretimi | elle fromJson/toJson>; alan adları sözleşmeyle (`<api/openapi.yaml>`) birebir.

## Dosya boyutu ve bölme
- Dosya başına bir public widget/sınıf; widget ≤ 150 satır, `build()` ≤ 60. Aşınca alt widget sınıfına çıkar (`_buildX` metodu değil).
- Ekran dosyası yalnızca yerleşim ve bağlama; iş kuralı notifier/provider'da; ağ çağrısı servis/repository'de. Provider dosyası ≤ 100 satır, provider başına dosya.

## Düzen (feature-first)
- `lib/features/<area>/{data,domain,presentation}/` — <seçilen düzen>; ortak `lib/core/`. Paylaşılan bileşenler `lib/shared/widgets/` ile başlar; bileşen sayısı 6'yı geçince ya da istenince ayrı paket `packages/<urun>_ui/` (token tabanlı, dartdoc Türkçe, golden + widgetbook; `tasarla` 5b). Üçüncü taraf widget kiti kullanılmaz.
- Rotalar: `lib/core/router.dart` + `features/<area>/routes.dart`; rota ve derin bağlantı parametresi sunucunun `publicId`'si (10 küçük harf), Guid değil. Tarih filtresi sunucuya `DateOnly` metni (`yyyy-MM-dd`) olarak gider; an UTC gelir, yerelde gösterilir.
- State: <Riverpod | Bloc | Provider>; `setState` yalnızca yerel, geçici UI durumu. Üretilmiş dosyalar elle düzenlenmez.

## Arayüz
- Pencere sınıfları dar < 600, orta 600–840, geniş > 840; `core/window_class.dart`. Dokunma hedefi ≥ 48 px; durum renk + metin; stiller temadan.
- Ekranlar küçük, yeniden kullanılan parçalardan kurulur (parça ≤ 150 satır, ekranın üçte birinden büyük bileşen bölünür); yoğun ve dolu yerleşim (özet + liste aynı ekranda, boş geniş alan yok); durum renkleri doygun ve metinle birlikte; mor-mavi gradyan, emoji simge, tek tip kart gölgesi gibi yapay zekâ kalıpları yok (`tasarla` mobil ilkeleri).
- Her ekranda boş, yükleniyor, hata ve çevrimdışı durumu.

## Çevrimdışı ve senkron (çevrimdışı modül varsa)
- Çevrimdışı modüller: <...>; yalnız saha/veri-toplama akışları çevrimdışı olur, onay/karar akışları çevrimiçi ister. Yerel DB: <Drift | Isar>.
- **Outbox deseni:** her yerel değişiklik tek outbox tablosuna sıralı komut olarak yazılır, FIFO gönderilir; medya ayrı kuyrukta (workmanager) metadan sonra gider. "Ne gönderilmedi" sorusunun cevabı her an bu tablodur.
- Kayıt kimliğini istemci üretir (**UUID v7**), her istek `Idempotency-Key` taşır; yeniden deneme bu sayede güvenlidir.
- Çakışma: <ekle-yalnız (gözlem/tespit verisi; kimse kimsenin kaydını ezmez) | rowversion + 409 (düzenlenen tek kaynak veri)>.
- Sunucunun 409 + mesaj anahtarı yanıtı veriyi silmez: kayıt cihazda "Gönderilemedi" kutusuna düşer, neden kullanıcının dilinde gösterilir.
- Ön paket: <birim: üstlenilen iş | rota | şube> tek seferde iner; <7 gün> sonra bayat sayılır, açılışta yeniden doğrulanır.
- Cihaz saati güvenilmez: kayıtta `createdAtLocal` + sunucuda `receivedAt`; sıralama ve rapor sunucu saatiyle.

## Güvenlik ve yayın
- Sır paketlere gömülmez (`--dart-define` dahil); belirteçler `flutter_secure_storage`; yayın `--obfuscate --split-debug-info`.
- Yalnız `stable` Flutter kanalı; pub paketlerinde ön sürüm (`-dev`, `-beta`, `-rc`) yok.
- Çökme raporlama <Sentry | Crashlytics>: yayın derlemesinde açık, semboller sürümle yüklenir. Her API isteğine `X-Correlation-Id`; hata ekranı bu kodu küçük gösterir ("Destek kodu"), kullanıcı destek talebinde okur.
- Fotoğraf yüklemeden önce sıkıştırılır (uzun kenar ≈ 1920 px, kalite ≈ 80); özgün dosya cihazda kalmaz.
- Platform izni Dart + `AndroidManifest.xml` + `Info.plist` birlikte; sertifika sabitleme <var | yok>.

## Test (üç katman)
- **Birim**: eşleyiciler, notifier/provider mantığı, hesaplar; mock: <mocktail | mockito>. Testte gerçek bekleme (`Future.delayed`, gerçek saat) yok; "şimdi" bir provider'dan gelir ve testte sabitlenir.
- **Widget / golden**: her ekran için widget testi; golden 390 / 800 / 1280 genişliklerinde.
- **Entegrasyon ve güvenlik**: `integration_test/` ile kritik akış <ör. giriş → kayıt → gönderim>; yetkisiz kullanıcı ekranı görmez testi; `flutter pub outdated` ve bağımlılık denetimi CI'da; paket içinde sır taraması (`guvenlik-testi`).
```
