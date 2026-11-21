# Proje etkisi: sürüm başına projelerde değişmesi gerekenler

Oturum başı hook'u bu dosyayı okur: projenin profilindeki `ekip-skills: <sürüm>` damgası yüklü sürümden eskiyse, aradaki sürümlerin maddelerini gösterir ve `kurulum güncelle` önerir. `kurulum güncelle` yalnız bu maddeleri uygular, kullanıcı onayıyla, sonra damgayı yükseltir.

Biçim (hook ayrıştırır): başlık `## X.Y.Z`, altında tek satırlık `- ` maddeleri. Yalnız proje dosyasını değiştiren maddeler yazılır; eklentinin kendi davranış değişiklikleri (eklenti güncellenince her projede kendiliğinden geçerli) buraya girmez. Yayında yeni sürümün maddeleri bu dosyaya eklenir.


## 0.12.1
- Profilde `Durum dosyası:` satırı durum yolunu belirler (hook'lar ve `devam` okur); durum dosyası başka yerdeyse satır eklenir.

## 0.13.0
- `.claude/rules/degismezler.md` (`paths:` yok, ≤ 40 satır): para, kiracı, denetim değişmezleri.
- `.gitattributes` BOM'suz UTF-8, ilk satır açıklama; .NET'te `.editorconfig` adlandırması (IDE1006 açık).
- Mevcut projede boyut borcu listesi (`docs/agent/borc.md` ya da projenin borç listesi).
- PostgreSQL 17+ ise arama sütunu üretilmiş sütun + `search_normalize_v1` + eşdeğerlik testi (`veri.md`).
- `altyapi.md`: belge commit'i PR'dan önce; Windows'ta yerel bağlantı `Host=127.0.0.1`.

## 0.14.0
- HTTP API varsa `.claude/rules/api.md` (dış/iç belge, `x-audience`, `operationId`, açıklamalı örnek, güvenlik); yoksa profilde `API: yok`.
- Profilde `ekip-skills: <sürüm>` damgası (bu uyarının kaynağı).

## 0.15.0
- `dotnet.md` test: kimlik, oran sınırlama ve kiracı çözümü HTTP üzerinden gerçek ara katmanlarla (`HttpContext` elle doldurulmaz).
- `veri.md` göç: veri dokunan göç dolu veritabanında, satır sayısıyla sınanır; RLS'li projede dar görünürlükle yazılır.
