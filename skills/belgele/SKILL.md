---
name: belgele
description: Proje geliştirilirken dokümanları kodla birlikte oluşturur ve günceller; karar kayıtları (ADR), son kullanıcı rehberleri ve eğitim materyali (rol bazlı), geliştirici rehberi, API başvurusu, değişiklik günlüğü. USE FOR — "dokümante et", "belgele", "rehber yaz", "eğitim dokümanı", "kullanım kılavuzu", "README güncelle", "ADR yaz", "document this", "write a guide", bir özellik bittiğinde, `uygula` raporunda "Belge etkisi" satırı doluysa. DO NOT USE FOR — mevcut bir metni çevirmek, yazım veya dil düzeltmek, sohbet içinde tek seferlik açıklama, koddaki tek yorum satırı.
argument-hint: "[özellik, karar veya doküman adı]"
---

# Belgele

Amaç: doküman kodla aynı anda doğsun ve kodla birlikte değişsin. Sonradan yazılan doküman eksik olur; güncellenmeyen doküman hiç olmamasından kötüdür, çünkü güvenilir sanılır.

## Dört doküman türü (Diátaxis)
Her doküman tek bir türdedir; türleri karıştırmak hepsini kullanışsız yapar.

| Tür | Kim için, ne zaman | Bu projede örnek | Yer |
|---|---|---|---|
| **Öğretici** (eğitim) | Yeni kullanıcı, ilk kez öğrenirken | "Saha personeli: ilk daire tespiti" | `docs/kullanici/<rol>/ogretici-*.md` |
| **Nasıl yapılır** (rehber) | Bilen kişi, bir işi yaparken | "Geri gönderilen kusuru yeniden tespit etme" | `docs/kullanici/<rol>/nasil-*.md`, `docs/gelistirici/nasil-*.md` |
| **Başvuru** | Bakıp kontrol ederken | API uç noktaları, durum kodları, yapılandırma | Koddan üretilir (aşağıda) |
| **Açıklama** | Neden böyle olduğunu anlamak isteyen | Karar kayıtları, mimari | `docs/kararlar/NNNN-*.md`, `docs/gelistirici/mimari.md` |

Başlıklar: **karar kaydı** Bağlam / Karar / Sonuçlar / Değerlendirilen seçenekler; **öğretici** Gerekenler / numaralı adımlar / Tamamladığında; **nasıl yapılır** Ne zaman / numaralı adımlar / Sorun olursa; **changelog** Keep a Changelog (Eklendi / Değişti / Düzeltildi / Kaldırıldı). Doldurulmuş örnekler: `references/sablonlar.md`.

## Ne zaman yazılır
- **Karar verildiğinde** (`sorgula`, `tasarla`, `planla` sırasında): geri alması pahalı her karar için karar kaydı. Kararı veren konuşma unutulur, kayıt kalır.
- **Kod yazılırken**: başvuru dokümanı koddan üretilir, elle yazılmaz. .NET'te XML doküman yorumları ve OpenAPI belgesi; Flutter'da dartdoc. Elle yazılan başvuru ilk değişiklikte bayatlar.
- **Yetki değiştiğinde**: `docs/yetki-matrisi.md` (rol × eylem tablosu, tek kaynak) aynı PR'da güncellenir; `guvenlik-testi` senaryoları bu matristen türetilir, matris değişmeden yetki kodu değişmez.
- **Özellik bittiğinde** (`uygula` raporunda "Belge etkisi" doluysa): ilgili rol rehberleri ve gerekiyorsa öğretici.
- **Yayında** (`yayin`): değişiklik günlüğü ve kullanıcıya dönük sürüm notu.

## Nasıl yazılır
1. **Davranışı kodu okuyarak veya çalıştırarak doğrula.** Plandan ya da hafızadan yazma; kodun yaptığını yaz.
2. **Her dokümanın başına** kapsam ve doğrulama bilgisi ekle:
   ```
   ---
   kapsam: [Tespit modülü, Mahal ekranı]
   rol: saha-personeli
   son_dogrulama: 2026-10-28 (commit abc1234)
   ---
   ```
   `incele`, değişen modülün kapsamına giren dokümanları bu satırdan bulur.
3. **Kullanıcı dili.** Son kullanıcı dokümanında teknik terim yok; ekrandaki etiket neyse o yazılır. Adım başına tek eylem. Ekran görüntüsü yoksa `[EKRAN: Mahal tespiti, Sorunlu seçili]` yer tutucusu; uydurma görüntü yok.
4. **Küçük dosya.** Her doküman tek konu, ≤ 150 satır; aşınca böl (ör. `nasil-onay-kutusu.md` → `nasil-kusur-onaylama.md` + `nasil-geri-gonderme.md`) ve haritada ikisini de listele.
5. **Haritayı güncelle.** Yeni dokümanı `docs/README.md` haritasına ekle; harita dışında kalan doküman bulunamaz.
6. **Rapor.** Oluşturulan/güncellenen dosyalar ve hangi kod değişikliğine bağlı oldukları.

## Bayatlama kontrolü
`belgele` çağrıldığında, kapsamı değişen koda dokunan ve `son_dogrulama` tarihi o değişiklikten eski olan dokümanları listele; kullanıcıya hangilerinin güncelleneceğini sor.
