# API belgesinin yapısı: bölümler, dizinler, açıklamalı örnek

Yöntem ve güvenlik kuralları: `api-belgeleri.md`. Kaynak: fintech-core ilk uygulamasının geri bildirimi (18.11.2026).

## Sabit bölüm şablonu (dış ve iç belge aynı iskelet)
1. **Kapak:** ürün, kitle (dış | iç), sözleşme/API sürümü, tarih. Dış kapakta commit kimliği yok; iç kapakta commit var.
2. **Sürüm geçmişi:** sürüm · tarih · değişiklik özeti (`oasdiff changelog`'dan); kırıcı değişiklik ayrı işaretli.
3. **İçindekiler** (otomatik).
4. **Giriş:** API ne işe yarar, kim kullanır, temel kavramlar (sözlükten).
5. **Ortamlar:** test ve canlı ortamın adı ve erişim yolu (yer tutucuyla; gerçek iç adres yok), erişim nasıl istenir.
6. **Kimlik doğrulama, adım adım:** numaralı adımlar; imzalı kanalda **ara değerli çalışılmış örnek** (kanonik metin → özet → imza → başlık; test anahtarıyla).
7. **Hata modeli:** `ProblemDetails` zarfı, `code`/`params`, `correlationId`; istemcinin genel tepkisi (yeniden dene, düzelt, destekle iletişim).
8. **Uç kartları, iş yeteneğine göre gruplu:** grup adı Türkçe ve açıklamalı (ör. "Hesaplar — banka hesaplarının listesi ve bakiyesi"). Her kart: amaç · yöntem + yol · yetki · istek (parametre/gövde tablosu) · yanıtlar tablosu (durum → anlam) · açıklamalı örnekler · olası hata kodları (dizine bağlantıyla).
9. **Hata kodu dizini:** kod · HTTP durumu · anlam · ne zaman olur · istemci ne yapmalı.
10. **Alan sözlüğü:** alan · tip ve biçim · anlam · örnek değer · hangi uçlarda.
11. **Deneme (Postman):** koleksiyonu içe aktarma, ortam değişkenlerini doldurma, ilk isteği çalıştırma; test anahtarının yalnız test ortamında geçtiği.
12. **Ekler:** sözlük, değişiklik bildirimi kanalı, iletişim.

## Üç dizin ve bekçileri
- **Uç dizini:** `operationId` · grup · yöntem + yol · kitle. `EndpointDataSource`'taki her uç dizinde (kitlesine göre dış ya da iç belgede).
- **Hata kodu dizini:** kodda üretilen her hata kodu (ör. `ApiErrorCodes` kaydı) dizinde açıklamasıyla; kayıtta olup dizinde olmayan ya da dizinde olup kayıtta olmayan kod → test kırmızı.
- **Alan sözlüğü:** dış yanıtlardaki her alan (dış OpenAPI şeması ya da sözleşme alan listesinden) açıklamasıyla; eksik alan → test kırmızı.
- Dizin açıklamaları elle yazılır (yan dosyada); kodla eşleşmesi testle korunur.

## Açıklamalı örnek
- **Veri testten, açıklama yan dosyada:** her örnek `<status>-<short-name>.json` yanında `<status>-<short-name>.md` (ya da tek YAML): **senaryo** (hangi durum), **ne zaman olur**, **alan açıklamaları** (yalnız örnekte geçen alanlar), hata örneğinde **istemci ne yapmalı**.
- **Bekçi:** açıklaması olmayan örnek, ya da örnekte olmayan bir alanı açıklayan not → test kırmızı. Böylece açıklama örnekle birlikte bayatlayamaz.
- Her uçta en az bir başarı ve bir hata örneği; hata üretmeyen uçlar adıyla istisna (`api-belgeleri.md` kurulum 6).
- Açıklama okuyucuya göre yazılır: dış belgede iç kavram, iç sınıf adı, iç tablo adı geçmez.
