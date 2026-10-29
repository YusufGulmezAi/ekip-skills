---
name: tasarla
description: Web, tablet ve telefon ekranlarını, iş kurallarını önce onaylatıp sonra tasarlar; her ekranı kullanım bağlamına (kim, nerede, ne yapıyor) ve pencere sınıfına göre kurar, koda aktarım notu bırakır. USE FOR — ekran tasarımı, arayüz, UI, mockup, wireframe, prototip, "ekran nasıl olsun", "tablet/mobil görünümü", "responsive", "screen design", "design the UI". DO NOT USE FOR — ekranı Flutter/Blazor koduna dökmek (`uygula`), görsel olmayan kapsam netleştirme (`sorgula`), tasarım sistemi token'larının kendisini üretmek.
argument-hint: "[ekran(lar) veya özellik]"
---

# Tasarla

Amaç: doğru şeyi, doğru cihaz için çizmek. Ekranda görünen her durum ve buton aslında bir iş kuralıdır. Kural onaylanmadan çizilen ekran, kural değişince baştan çizilir. Bu yüzden sıra: bağlam → kararlar → çizim.

## 1. Ekran envanteri
Her ekran için tek satır, tablo halinde: **kim** (rol), **nerede** (cihaz + ortam: masa başı, şantiye, bodrum), **ne yapıyor** (tek fiil), **ne sıklıkla**. Proje profilinde roller varsa oradan al. Bu tablo, aynı işin telefonda ve web'de neden farklı göründüğünün gerekçesidir.

## 2. Pencere sınıfı
- **Dar (< 600 px, telefon):** tek sütun, alt gezinme, liste ve detay ayrı ekran.
- **Orta (600–840 px, tablet dikey):** gezinme rayı, liste + detay yan yana.
- **Geniş (> 840 px, tablet yatay ve web):** kalıcı menü, tablo, çok sütunlu form.
Her ekranın birincil sınıfını envanterden çıkar; yalnızca o sınıf için tam tasarım, diğerleri için yerleşim notu. Ayrıntılı desenler: `references/pencere-siniflari.md`.

## 3. Tasarım sistemi
Profilde adı geçen sistemi kullan; yoksa kullanıcıya sor. Hiç yoksa küçük bir set öner (6–10 renk, 5–7 metin stili, 4 boşluk, 3 yarıçap) ve bunun geçici olduğunu söyle. Sistemin kuralı bağlamla çelişiyorsa (masaüstü öncelikli sistem + saha uygulaması) sessizce ezme; çelişkiyi karar sorusu yap.

## 4. Kararlar önce
Ekranda görünecek iş kurallarını (durum geçişleri, kim neyi onaylar, hangi alan zorunlu, çevrimdışı davranış, hata/geri gönderme yolu) **çizmeden önce** numaralı sorular olarak sor; her soruda önerilen cevap ve gerekçe, "evet" öneriyi kabul etsin. Onay gelmeden çizme. Onaylanan önemli kararlar `belgele` ile karar kaydına (ADR) gider.

## 5. Çiz
**Yapay zekâ üretimi hissi veren hiçbir şey teslim edilmez; bu her platform için geçerlidir** (`references/mobil-ilkeler.md`, "Yapay zekâ üretimi görünümünden kaçınma" başlığı: mor-mavi gradyan, emoji simge, tek tip kart, her şeyi ortalama, uydurma istatistik, kalıp "hoş geldiniz" ekranı). Teslimden önce her ekranı bu listeyle kontrol et; bir madde varsa ekran bitmemiştir. Referans alınacak şey sektörün gerçek uygulamaları ve ürünün kendi verisidir, yapay zekâ üretimi örnek ekranlar değil. Mobil ve tablette ayrıca küçük bileşen, yoğun ekran ve canlı renk ilkeleri geçerlidir.

**Gerektiğinde mockup:** tartışılacak, onaylatılacak veya ekibe/müşteriye gösterilecek her ekran için önce mockup üretilir (tasarım tuvali ya da HTML); kod ancak mockup onaylandıktan sonra. Küçük düzeltme (bir etiket, bir renk) mockup gerektirmez. Mockup gerçek pencere boyutunda (390 / 800 / 1280) ve gerçek yoğunlukta örnek veriyle; "Örnek veri" etiketi.
- Oturumda hangi araç varsa onu kullan (tasarım tuvali, Figma, HTML mockup); yoksa sor.
- Gerçekçi örnek veri, "Örnek veri" olarak işaretli. Lorem ipsum yok.
- Her ekran için şu durumları düşün, en az birini göster: boş, yükleniyor, hata, çevrimdışı, yetkisiz.
- Erişilebilirlik: dokunma hedefi en az 44 px (saha ve eldivenli kullanım: 48 px); durum yalnızca renkle anlatılmaz (renk + metin); metin kontrastı 4.5:1; gerçek `<button>`/`<label>`.

## 5b. Özel bileşen kütüphanesi (istendiğinde)
Kullanıcı isterse ya da aynı parça üç ekranda tekrar ediyorsa ekibin kendi bileşen kütüphanesi kurulur; hazır kit (üçüncü taraf widget paketi) yerine tasarım sistemi token'larından türeyen kendi bileşenler. Gerekçe: hazır kit "yapay zekâ/şablon" görünümünü ve bağımlılık riskini getirir; kendi kütüphane ürünün dilini taşır. Kurallar:
- Flutter: ayrı paket `packages/<urun>_ui/` (ör. `tespit_ui`), uygulama ona bağımlı, tersi değil. Bileşen başına dosya (≤ 150 satır), Türkçe dartdoc, en az bir widget testi ve golden; kataloğu `widgetbook` ile (her bileşenin tüm durumları: boş, dolu, hata, devre dışı). Web Blazor ise `src/<Urun>.Ui/` Razor sınıf kütüphanesi, aynı token'lar.
- Önce envanter: mockup'lardaki parçalar listelenir (rozet, sayaç, segmentli seçici, foto küçük resmi, liste satırı, durum şeridi); en çok tekrar edenden başlanır, kütüphane küçük doğar (6–10 bileşen) ve ihtiyaçla büyür.
- Renk, yazı, boşluk doğrudan yazılmaz; token'dan gelir (tasarım sisteminin `tokens.json` → Flutter `ThemeExtension`). Tema değişince bileşen değişmez.
- Bir bileşen kütüphaneye girdikten sonra ekranlar onu kullanır; ekranda aynı işi yapan yerel widget `incele`'de bulgudur.
- Kütüphane sürümlenir (`CHANGELOG`), kırıcı değişiklik karar kaydı ister; `belgele` bileşen başına kısa kullanım notu üretir (dartdoc'tan).

## 6. Onay kapısı ve koda aktarım notu
Mockup, **geliştirici (ya da ürün sahibi) onaylamadan koda dökülmez.** Onay alınınca aktarım notunun başına yazılır: `Onay: <kişi>, <tarih>, <mockup bağlantısı/dosyası>`; onaylanmamış mockup'ın notu "Onay: bekliyor" taşır ve `uygula` bunu uygulamaz. Onay bekleyen notun **açık soruları kapatılmaz**: kullanıcı "önerilerini kabul et" demiş olsa bile tasarım kararı notta `Öneri (onay bekliyor): ...` diye yazılır, "Karar:" diye değil — mockup onayı yalnızca açık onayla gelir. Değişiklik isteği gelirse mockup güncellenir ve onay yenilenir; kodda düzeltme yapılmaz. Gerekçe: ekran kodu tasarım tartışmasının en pahalı yeridir; iki kez yapılacaksa mockup'ta yapılsın.

Her ekran için kısa not: bileşen listesi (tasarım sisteminden), gösterilen veri alanları ve kaynağı (API uç noktası), durumlar, pencere sınıfına göre farklar. Bu not `planla`'nın girdisidir; ekranı koda döken `uygula` buna bakar.
