# Web (masa başı, Blazor) ekran ilkeleri

Geniş pencere sınıfı (> 840 px) ve web uygulaması için; `mobil-ilkeler.md`'deki yapay zekâ görünümü yasakları burada da geçerlidir.

## Onay akışı
- **Bileşen ve ekran ayrı onaylanır.** Yeni bileşen, projedeki canlı katalog sayfasında (yalnız geliştirme ortamında açık) dört durumuyla gösterilir: dolu, boş, hata, devre dışı. Onay orada alınır ve onay kaydına katalog sürümüyle yazılır.
- **Bileşenler teker teker incelenir.** Toplu sunma yok: bir bileşen katalogda ve gerçek ekranda incelenir → geri bildirim → düzeltme → onay → sonraki.
- **Geri bildirim önce spesifikasyona yazılır, sonra kodlanır.** Bileşen spesifikasyonu (karar maddeleri numaralı) tek doğru kaynaktır; onaylı maddeden sapma yok, belirsizlikte sorulur.
- **Her form için yerleşim sorulur:** yeni sayfada mı, sağdan açılan çekmecede mi? Kod yazmadan önce, seçenekli soru olarak.
- **Yerleşik desenin yeni örneği** (mevcut bileşenlerle, onaylı liste/form deseninde yeni ekran; mevcut forma alan ekleme) ayrı mockup istemez: çalışan ekranda dört durum gösterilir, onay yazılı alınır. Yeni düzen, yeni akış ya da yeni bileşen bu istisnaya girmez.

## Yerleşim
- Özet önce, ayrıntı sonra: sayaçlar → tablo → seçili kayıt paneli.
- Tablo: süzgeç çubuğu, sütun seçimi, sayfalama, toplam satırı, sayılar sağa hizalı ve `tabular-nums`; tablo yatay kaydırma kutusunda, sayfa gövdesi yana kaymaz.
- Toplu işlem (çoklu seçim + tek eylem) inceleme ve onay işlerinde.
- Sayfa genişliği ve başlık altı açıklama gibi kararlar projenin tasarım sistemindedir; eklenti dayatmaz.

## Sayfa yazımı
- Sayfalar ham kontrol (`<input>`, `<select>`) yazmaz; ortak bileşen kütüphanesini kullanır. Bunu bir mimari test zorlayabilir.
- Doğrulama tek yerde: doğrulayıcı sözleşme katmanında, form ve servis aynı doğrulayıcıyı kullanır.
- Kullanıcıya görünen her metin Türkçe ve kaynak dosyasından; tarih `gg.aa.yyyy`, tutar `1.250,50`, sıralama Türkçe alfabe.
- Durumlar: boş, yükleniyor, hata, yetkisiz; hata satırın yanında ve metinle, yalnız renkle değil.
- Statik SSR'da etkileşim sunucu gidiş-dönüşüdür: arama ve süzme GET formu, kaydetme POST; anlık davranış küçük, idempotent JS ile. Tuzaklar: `incele/references/blazor-ssr.md`.
