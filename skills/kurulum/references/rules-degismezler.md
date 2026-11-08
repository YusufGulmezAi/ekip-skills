# `.claude/rules/degismezler.md` şablonu (≤ 40 satır, `paths:` YOK)

Neden ayrı ve kapsamsız: para, kiracı ve denetim değişmezleri planlama oturumunda da gerekir. `paths:` kapsamlı dosyalar ancak eşleşen dosya (ör. `.cs`) açılınca yüklenir; plan kod açmadan yapıldığında değişmez görünmez ve plan onu çiğneyebilir. Bu dosya her oturumda yüklenir, bu yüzden kısa kalır ve yalnız **ne**yi söyler; **nasıl** (EF filtresi, önleyici, test sınıfı) kapsamlı dosyalarda (`dotnet.md`, `veri.md`) kalır. Projede karşılığı olmayan bölüm silinir.

```markdown
# Değişmezler

Her plan, kod ve inceleme bunlara uyar. Değişmezi etkileyen görev bunu açıkça yazar ve kullanıcı onayı ister.

## Para
- Tutar `decimal` + para birimi (<TRY>); `double`/`float` yok. Yuvarlama <MidpointRounding.ToEven | AwayFromZero>, yalnız <satır | belge> toplamında.
- Kesinleşmiş tutar değiştirilmez; düzeltme ters kayıtla yapılır. Toplamlar kalemlerden türetilir, ayrıca saklanan toplam kalemlerle eşit olmalı.

## Kiracı
- Her kiracılı kayıt tek bir kiracıya aittir; başka kiracının kaydı hiçbir yoldan (liste, PublicId, rapor, dışa aktarma) görünmez: 404.
- Kiracılar arası işlem yok <istisna: ...>. Kiracı filtresini kaldıran her kullanım karar kaydıyla.

## Denetim
- <Para, yetki, kişisel veri> değişikliği kim · ne zaman · eski → yeni olarak ekle-yalnız günlüğe yazılır; günlük güncellenmez ve silinmez.
- Kullanıcı eylemi silinmez, durum değiştirir (<iptal | arşiv>); kalıcı silme yalnız KVKK talebiyle ve kayıtlı.
```
