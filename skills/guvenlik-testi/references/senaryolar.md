# Güvenlik test senaryoları kataloğu

Her satır bir test. Ad kalıbı: `<Aktör>_<Eylem>_<Beklenen>`.

## Kimlik ve yetki
- Kimliksiz istek her korumalı uç noktada 401.
- Yanlış rol (emlak ofisi, müteahhit uç noktasını çağırır) 403.
- Süresi dolmuş / geçersiz imzalı belirteç 401; belirteç başka ortamın anahtarıyla imzalıysa 401.
- Rol yükseltme: istek gövdesinde `rol` alanı gönderilirse yok sayılır.

## Çok kiracılılık (en kritik)
- Başka firmanın kaydı id ile okunursa 404 (403 değil: varlığı sızdırmaz).
- Başka firmanın kaydı güncellenir/silinirse 404 ve veri değişmez.
- Liste uç noktaları yalnızca kendi firmanın kayıtlarını döner (sayı ve id doğrulaması).
- Raporlama ve toplu işlemler de filtreye tabi; `IgnoreQueryFilters` kullanan her sorgu için ayrı test.
- Başka sitenin kaydı `PublicId` ile istenirse de 404; biçimsiz `PublicId` (büyük harf, rakam, Türkçe harf, 9/11 karakter) 404; yanıtlarda iç `Guid` görünmez; ardışık kayıtların `PublicId`'leri tahmin edilebilir örüntü taşımaz.

## Girdi doğrulama
- Çok uzun metin (10 KB), boş, yalnızca boşluk, kontrol karakterleri → 400.
- SQL ve komut enjeksiyon kalıpları (`' OR 1=1`, `; --`) düz metin olarak saklanır, sorguyu değiştirmez.
- Tarih ve sayı alanlarında sınır dışı değer (negatif tutar, 9999 yıl) → 400.
- Sıralama/filtre parametreleri beyaz listeyle; bilinmeyen alan 400.

## Dosya yükleme (fotoğraf, video)
- Uzantı ve içerik türü ayrı doğrulanır (`.jpg` adlı `.exe` reddedilir, içerik sihirli bayt kontrolü).
- Boyut sınırı (ör. 20 MB) aşımı 413; sınırda istek başarılı.
- Yüklenen dosya web kökünden çalıştırılamaz; sunulurken `Content-Disposition` ve doğru `Content-Type`.
- Başka firmanın dosyası doğrudan URL ile indirilemez (imzalı, süreli bağlantı); süresi dolmuş imzalı URL 403.
- Yüklenen görselin sunucudaki ve indirilen kopyasında EXIF/GPS meta verisi yok (konum sızıntısı testi: GPS'li örnek fotoğraf yüklenir, indirilen dosyada `exiftool` ile aranır).

## Oturum ve hız
- Aynı IP'den 1 dakikada N başarısız giriş → kilit/yavaşlatma (429).
- Parola sıfırlama belirteci tek kullanımlık ve süreli.
- Çıkışta belirteç geçersiz (varsa sunucu tarafı iptal).

## Mobil (Flutter)
- Derlenmiş paket içinde API anahtarı, parola, bağlantı dizesi yok (`strings` taraması).
- Belirteç `flutter_secure_storage`'da; `SharedPreferences`'ta değil.
- Yetkisiz kullanıcı ekranı açarsa boş/yönlendirme; veri çağrısı yapılmaz (widget testi).
- Üretim paketi test API'sine bağlanamaz; sertifika doğrulaması kapatılmamış (`badCertificateCallback` yok).
- Aynı `Idempotency-Key` ile tekrarlanan istek ikinci kaydı açmaz (tek kayıt doğrulaması); başka kullanıcının anahtarıyla gönderilen istek onun kaydına dönmez.

## Altyapı (manuel kontrol listesi, yayın öncesi)
- HTTP → HTTPS yönlendirme, HSTS; güvenlik başlıkları (CSP, X-Content-Type-Options, frame-ancestors).
- Hata yanıtlarında yığın izi yok (`Development` dışı).
- VPS: yalnızca 22/80/443 açık, SSH parola girişi kapalı, `fail2ban` aktif.
