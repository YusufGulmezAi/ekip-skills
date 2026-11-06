---
name: planla
description: Onaylanmış bir isteği veya tasarımı, her biri tek oturumda bitirilebilecek dikey dilimlere böler; her göreve sahip (dotnet, flutter, test, belge), bağımlılık, bitti ölçütü ve belge etkisi yazar, planı dosyaya kaydeder. USE FOR — "planla", "görevlere böl", "iş paketlerine ayır", "yol haritası çıkar", "plan this", "break it down", `sorgula` veya `tasarla` onaylandıktan sonra, backend ve mobile birlikte dokunan işler. DO NOT USE FOR — tek dosyalık küçük değişiklik (doğrudan `uygula`), henüz netleşmemiş istek (`sorgula`).
argument-hint: "[özellik veya onaylanmış özet]"
---

# Planla

Amaç: işi, bağımsız doğrulanabilen ve gerektiğinde paralel yürütülebilen parçalara bölmek. Plan `orkestra`'nın girdisidir; tek kişilik işte de `uygula`'nın sırasını belirler.

## Kurallar
1. **Dikey dilim.** Plan önce **davranışlara** bölünür (örn. "müteahhit kusuru üstlenir", "müteahhit taşerona atar", "taşeron atananları görür"); her davranış bir dilimdir ve kendi başlığı altında sahip bazlı görevlerini taşır (dotnet uç noktası, flutter ekranı, test). Görevler plan genelinde "önce tüm backend, sonra tüm mobil" diye katmana göre gruplanmaz. Gerekçe: dilim tek başına çalıştırılıp gösterilebilir; katman planında hiçbir şey sona kadar çalışmaz. Birden fazla dilim aynı sözleşmeye dayanıyorsa sözleşme görevi ortak Dalga 1'dir.
2. **Sözleşme önce.** .NET ile Flutter arasındaki API değişiyorsa ilk görev sözleşmedir (OpenAPI veya DTO tanımı + örnek yanıt + yeni mesaj anahtarları `docs/mesajlar.md`'ye). Sözleşme sabitlenince backend ve mobil görevleri paralel yürür; sabitlenmezse biri diğerini bekler.
3. **Tek bağlama sığar.** Bir görev bir ajanın tek oturumda bitirebileceği büyüklükte olmalı (birkaç dosya, tek modül). Büyükse böl.
4. **Paralellik işareti.** `[P]` yalnızca başka bir paralel görevle aynı dosyalara veya aynı migration'a dokunmayan görevlere konur. Emin değilsen koyma; yanlış `[P]` çakışma üretir.
5. **Dosya yolu değil modül adı.** Yollar plan yazıldıktan sonra değişir; görev "Tespit modülü, Kusur varlığı" gibi alan adıyla tarif edilir.
6. **Belge etkisi.** Her görev hangi dokümanı etkilediğini söyler (karar kaydı, kullanıcı rehberi, API başvurusu) ya da "yok".
7. **Ekran görevi onaylı ekrana bağlıdır.** Her ekran görevi `[bağlı: ekran onayı — <ekran adı>]` taşır (onay yüzeyi profilde; varsayılan mockup); onay yoksa önce `tasarim` sahipli görev. Onaysız ekran görevi dalgaya girmez.
8. **Test üç katman.** Veri veya yetki değiştiren her dilimde `test` sahipli görev üç katmanı sayar: birim, entegrasyon, güvenlik (kiracı/yetki senaryoları `guvenlik-testi` kataloğundan).
9. **Veri modeli önce.** Entity veya şema değiştiren dilimin ilk görevi `[sahip: dotnet] Model önerisi`dir: alanlar (ad, tip, zorunluluk ve **neden**), ilişkiler, kısıtlar (hangi iş kuralını şemada zorluyor), kapsam dışı. Onaylanmadan migration görevi dalgaya girmez. Gerekçe: yazılmış modeli değiştirmek (migration, veri göçü, bağımlı kod) öneriyi değiştirmekten kat kat pahalıdır.

## Görev satırı biçimi
```
- [ ] G03 [P] [sahip: flutter] [bağlı: G01] Mahal tespit ekranı, kriter durumu kaydetme
      Bitti: sorunlu kriter fotoğrafsız kaydedilemez; widget testi geçer
      Belge: kullanıcı rehberi "Tespit yapma"
```
Sahipler: `dotnet`, `flutter`, `test`, `belge`, `tasarim`. Görev numarası dilimi taşır (D1-G1, D1-G2, D2-G1 ...), böylece hangi görevin hangi davranışa ait olduğu panoda görünür.

## Çıktı
1. Planı `docs/planlar/<YYYY-MM-DD>-<kisa-ad>.md` dosyasına yaz: başta amaç ve bitti ölçütü (sorgula özetinden), sonra dalgalar halinde görevler. Dalga = aynı anda başlayabilen görevler.
2. Kullanıcıya planın özetini göster: görev sayısı, dalga sayısı, kritik yol. Onay iste.
3. Onaydan sonra: 3+ görev ve birden fazla sahip varsa `orkestra`, yoksa görevleri sırayla `uygula`.
