# Yapılacaklar: v0.12.1 ve v0.13

Kaynak: Akses ve fintech-core'da v0.12.0 kullanımı, 06–08.11.2026. Projelerde '[ekip-skills]' etiketiyle yazılan yeni dersler buraya eklenir.

> Numaralar kaynak listedeki sırayı korur (12 v0.12.1'e alındı); madde atıfları bu numaralarla yapılır.

## v0.12.1 — hook'lar ve süreç (öncelikli) — yapıldı (1, 2, 3, 4, 12)

- **1.** Stop hook kurulmamış projede de devreye giriyor (fintech-core): ne "## Proje profili" ne durum dosyası varken ve değişiklikler oturumdan önce varken `durum.md` yazdırmaya çalıştı. Düzeltme: profil ya da durum dosyası yoksa sessiz kal; yalnız bu oturumda değişen dosyaları say (oturum başı zaman damgası).
- **2.** Stop hook "30 satırı geçme" diye sabit sınır söylüyor (Akses'te sınır 60). Düzeltme: "projenin durum dosyası kuralına uy (yoksa ≤ 30 satır)". Yalnız öneri dosyası yazan tasarım oturumunda da durum istemesi kullanıcının "tek dosya yaz" talimatıyla çatışıyor.
- **3.** SessionStart durum dosyasının ilk 2500 baytını veriyor; Akses'te tablonun ortasında kesiyor, "Sıradaki" gelmiyor. Düzeltme: önce "Sıradaki|Sonraki|Açık" başlıklı bölümler, sonra kalan bütçeyle baştan; toplam çıktı ≤ 10.000 karakter.
- **4.** `devam`: `docs/agent/durum.md` yoksa "dur" diyor; profildeki "Durum dosyası" satırını ve `docs/DURUM.md` geri dönüşünü okumalı.
- **12.** Kanıt sırası: `--no-build` ile koşan takım eski ikiliyi sınar, sahte kırmızı/yeşil üretir (fintech-core D4). `uygula`/`orkestra`: önce derleme başarılı, sonra testler; derleme kırmızıysa testler başlamaz. Ayrıca: alt ajanın "geçti" raporu yetmez, ana oturum kendi komutuyla doğrular.

## v0.13 — kurulum ve kural içeriği

- **5.** `incele`: `ILike` + `tr-TR-x-icu` harf kuralı için doğru; yalnız şapka ve `%x%` indeksi eksikliği borçtur. "ILIKE kullanımı bulgu" genellemesi yapılmamalı.
- **6.** Dosya boyu (C# 200, doküman 150): mevcut projede eşik yalnız yeni dosyalara; aşan eskiler borç listesinde, dokunulması bölmeyi zorunlu kılmaz. `kurulum` ve `incele`'ye yazılmalı.
- **7.** Arama sütunu: SaveChanges önleyicisi `HasData` tohumlarını, migration INSERT'lerini, `ExecuteUpdate`'i atlar → sütun boş/bayat kalır; geri dolumda migration C# çalıştıramaz. PG17+ önerisi: `<alan>_arama text GENERATED ALWAYS AS (fn(<alan>)) STORED`; fn IMMUTABLE SQL, `pg_c_utf8` (I→ı, İ→i çevirisi → `lower(... COLLATE pg_c_utf8)` → ı+U+0307→i → âîû→aiu, U+0302/U+0307 silinir → boşluk sadeleşir). Terim ve bellek içi arama C# `TextNormalizer`. Eşdeğerlik testi zorunlu (vektörler + kod noktası taraması; C# ve JS aynı JSON vektör dosyasını okur). Fonksiyon `CREATE OR REPLACE` ile değişmez: yeni ad + `ALTER COLUMN … SET EXPRESSION`. Bayatlık testi: `x_arama IS DISTINCT FROM fn(x)` = 0. Benzersizlik arama sütununa taşınır. Tuzak: `INSERT … SELECT *` kopyaları kırılır. `rules-veri.md` + başvuru kodu (SQL fonksiyonu + eşdeğerlik testi). Kaynak: Akses ADR-017 eki, IP-089…092.
- **8.** Başvuru `TextNormalizer` UTF-16 char döngüsüyle çalışıyor; temel düzlem dışı harfleri (U+10400) küçültmez, PostgreSQL küçültür. Düzeltme: `Rune` düzeyi; testlere U+10400, U+1E900.
- **9.** `.gitattributes` BOM'suz yazılmalı: BOM ilk kuralı (`* text=auto eol=lf`) etkisiz bırakıyordu (fintech-core: 805 dosya CRLF, "M" görünen üretilmiş dosyalar, `dotnet format`'ta 87 bin hata). `kurulum` BOM'suz yazar, ilk satırı açıklama yapar; doktor betiği BOM'u denetler.
- **10.** `.editorconfig` adlandırma: `private static readonly` ve yerel `const` için kural yoksa IDE1006 yüzlerce ihlal üretir; `kurulum` projenin alışkanlığını okuyup kurala yazar, IDE1006 açık kalır.
- **11.** Değişmezler (para, kiracı, denetim) `paths:` olmayan tek dosyada (ör. `degismezler.md`, ≤ 40 satır) tanımlanmalı; kapsamlı dosyalarda yalnız uygulama ayrıntısı. Planlama oturumu `.cs` açmadan çözüm önerir.
- **13.** Belge commit'i PR açılmadan önce atılır; PR'a sonradan eklenen commit CI'ı yeniden başlatır, koşan iptal olur (Akses).
- **14.** Windows'ta yerel PostgreSQL bağlantısı `localhost` yerine `127.0.0.1` (IPv6 denemesi ~2 sn/bağlantı; Akses akış testleri 1 sa → 8 dk). `rules-altyapi.md` / doktor betiği.
