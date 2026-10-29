# Pencere sınıfları ve yerleşim desenleri

Kırılma noktaları Material 3 pencere sınıflarıdır. Ölçüt cihaz değil, **uygulamanın aldığı genişliktir**: bölünmüş ekrandaki tablet "dar" sayılır.

| Sınıf | Genişlik | Gezinme | Liste/detay | Form |
|---|---|---|---|---|
| Dar | < 600 | Alt çubuk (3–5 hedef) veya geri tuşu | Ayrı ekranlar | Tek sütun, alt sabit eylem çubuğu |
| Orta | 600–840 | Gezinme rayı (sol) | Yan yana (liste ~300 px) | İki sütun yalnızca kısa alanlarda |
| Geniş | > 840 | Kalıcı menü veya üst menü | Yan yana + üçüncü panel mümkün | Çok sütun, tablo içi düzenleme |

## Saha ekranları (telefon/tablet)
- Birincil eylem başparmak bölgesinde: alt kenar.
- Segmentli seçim (Uygun / Sorunlu / Yok) açılır listeden hızlıdır: tek dokunuş, durum görünür.
- Kamera ve dosya ekleme bağlamın içinde (kriterin yanında), ayrı ekranda değil.
- Çevrimdışı durum görünür ve kalıcı: bekleyen yükleme sayısı.
- Uzun listede ilerleme göstergesi ("7 mahalden 4'ü").

## Masa başı ekranları (web)
- Özet önce, ayrıntı sonra: sayaçlar → tablo → seçili kayıt paneli.
- Toplu işlem (çoklu seçim + tek eylem) onay ve inceleme işlerinde zaman kazandırır.
- Tablolar yatay kaydırma kutusunda; sayfa gövdesi yana kaymaz.
- Bekleme ve gecikme süresi görünür; geciken kayıt renk + metinle işaretli.

## Flutter karşılığı
- Sınıfı `MediaQuery.sizeOf(context).width` ile belirle; bileşen içinde ise `LayoutBuilder`.
- Tek bir `enum WindowClass { compact, medium, expanded }` ve tek yardımcı fonksiyon; ekranlarda sayı yazma.
- Dar → `NavigationBar`, orta → `NavigationRail`, geniş → `NavigationRail(extended: true)` veya `NavigationDrawer`.
- Golden testler her sınıf için ayrı genişlikte (390, 800, 1280) çekilir.
