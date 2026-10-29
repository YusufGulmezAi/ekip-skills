---
name: guvenlik-testi
description: Bir özellik veya sürüm için tehdit modeli çıkarır ve saldırı senaryolarını otomatik güvenlik testlerine çevirir (.NET SecurityTests, Flutter sır ve yetki testleri, CI'da bağımlılık ve ZAP taraması); bulguları öncelikli raporlar. USE FOR — "güvenlik testi", "saldırı testi", "hacking testi", "penetrasyon", "pentest", "security test", "threat model", "OWASP", yeni uç nokta/ekran eklendiğinde, yayından önce, çok kiracılı veri veya kimlik doğrulama değiştiğinde. DO NOT USE FOR — genel kod incelemesi (`incele`), işlevsel test yazımı (`uygula`), üretim sistemlerine izinsiz saldırı (yalnızca ekibin kendi sistemleri, yazılı izinle).
argument-hint: "[özellik, uç nokta, ekran veya sürüm]"
---

# Güvenlik testi

Amaç: saldırganın deneyeceği şeyi, saldırgandan önce ve her CI koşusunda denemek. Tek seferlik pentest bayatlar; teste dönüşmüş saldırı senaryosu her değişiklikte yeniden koşar. Kapsam yalnızca ekibin kendi sistemleri; dış sistemlere ve izinsiz üretim ortamına test yapılmaz.

## 1. Tehdit modeli (özellik başına 10 satır)
Tablo: **varlık** (neyi koruyoruz: ör. kayıt verisi, fotoğraf, kimlik), **aktör** (başka firmanın kullanıcısı, yetkisiz rol, kimliksiz istemci, kötü niyetli iç kullanıcı), **giriş noktası** (uç nokta, dosya yükleme, derin bağlantı), **kötüye kullanım** (bir cümle). Çok kiracılı sistemde ilk satır her zaman "başka firmanın verisini okuma/yazma". Kişisel veri taşıyan varlıkların saklama süresi kararı (ADR) yoksa raporda öner (KVKK).

## 2. Senaryo → test
Her kötüye kullanım satırı bir teste dönüşür; test adı senaryoyu söyler (`OtherTenant_CannotReadDefect_Returns404`). Yetki senaryoları `docs/yetki-matrisi.md`'den türetilir (varsa); kodda matriste olmayan erişim **Kritik** bulgudur. Katalog: `references/senaryolar.md` (yetki, kiracı, girdi, dosya, oturum, mobil). Testler `tests/<Project>.SecurityTests/` ve Flutter `test/security/` altında; `WebApplicationFactory` ile gerçek ara katmanlar, sahte kimlik sağlayıcıyla rol/kiracı değiştirilir.

## 3. Otomatik tarama (CI)
- Bağımlılık: `dotnet list package --vulnerable --include-transitive`, `flutter pub outdated`; kritik zafiyette CI kırmızı.
- Dinamik: OWASP ZAP baseline taraması test ortamına karşı (`zap-baseline.py -t <test-url>`), yalnızca ekibin kendi test ortamında.
- Sır taraması **iki katman:** commit öncesi yalnız değişiklik (`gitleaks protect --staged`) **ve** her güvenlik testinde depodaki tüm izlenen dosyalar (`gitleaks detect --no-banner`; yoksa `git grep -nEi '(password|pwd|secret|apikey|token)\s*[=:]' -- ':!*.md'`) + derlenmiş mobil paket (`strings | grep`). Yalnız diff'e bakan tarama, git'te zaten izlenen sırrı göremez; "eşleşme yok" demek için hangi katmanın tarandığı yazılır. İzlenen sır **Kritik**: döndürme, `user-secrets`/ortam değişkenine taşıma ve geçmiş temizliği önerilir.
- Ortam verisi: Test ve Demo veri tabanında gerçek müşteri verisi aranır (üretimden kopya, gerçek ad/telefon kalıpları); bulunursa **Kritik** (KVKK). Demo'nun erişim kısıtı (basic-auth/IP) doğrulanır.
Komutlar çalıştırılamıyorsa raporda "yapılmadı" ve tam komut.

## 4. Rapor
Rapor **her zaman tehdit modeli tablosuyla başlar** (adım 1), sonra bulgular gelir; bulgulardan başlayan rapor hangi senaryonun kapsandığını göstermez. Bulgular `incele` biçiminde (**Kritik / Önemli / Öneri**, kanıt, düzeltme); her bulgu için eklenen veya eklenecek testin adı. Düzeltme `uygula` ile, bulgu kapanınca test kalır. Yayın öncesi `yayin` bu raporu ister.

## Sınırlar
Exploit kodu, gerçek zararlı yük veya üçüncü taraf sistemlere tarama üretilmez; testler kendi uygulamanın yanlış davranışını kanıtlayan asgari istekle yazılır.
