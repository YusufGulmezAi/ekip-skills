# Doküman şablonları

## Karar kaydı (ADR) — `docs/kararlar/NNNN-kisa-ad.md`
```markdown
---
durum: kabul edildi        # önerildi | kabul edildi | yerini aldı: NNNN
tarih: 2026-10-28
kapsam: [Onay akışı]
---
# NNNN. Onay akışı kusur düzeyinde yürür

## Bağlam
Müşavir bir dairenin bazı kusurlarını onaylayıp bazılarını geri göndermek istiyor. Daire düzeyindeki akışta tek eksik fotoğraf tüm daireyi bekletir.

## Karar
Durum kusur düzeyinde tutulur; daire durumu kusurlarından türetilir.

## Sonuçlar
- Kısmi onay mümkün; sorunlu olmayan kusurlar beklemeden müteahhide gider.
- Durum makinesi kusur varlığında; raporlar daire durumunu hesaplar.
- Daire düzeyinde tek imzalı "teslim tutanağı" ayrıca üretilmeli.

## Değerlendirilen seçenekler
- Daire düzeyinde akış: daha basit, ama bekleme süresi uzun.
```

## Öğretici — `docs/kullanici/<rol>/ogretici-*.md`
```markdown
---
kapsam: [...]
rol: <rol>
son_dogrulama: <tarih> (commit <kısa hash>)
---
# <Rol>: <ilk başarılı iş>

Bu öğreticide <ne öğrenileceği, bir cümle>. Süre: yaklaşık <N> dakika.

**Gerekenler:** <hesap, cihaz, örnek veri>

1. <Tek eylem>. [EKRAN: ...]
   <Ne görmeli: bir cümle.>
2. ...

**Tamamladığında:** <kullanıcının artık yapabildiği şey>. Sonraki adım: <nasıl-yapılır rehberine bağlantı>.
```

## Nasıl yapılır — `docs/kullanici/<rol>/nasil-*.md`
```markdown
# <İş> nasıl yapılır

**Ne zaman:** <hangi durumda bu rehbere bakılır>

1. <Tek eylem>.
2. ...

**Sorun olursa:** <en sık iki sorun ve çözümü>.
```

## Değişiklik günlüğü — `CHANGELOG.md` (Keep a Changelog biçimi)
```markdown
## [1.4.0] - 2026-11-03
### Eklendi
- Müşavir kusurları tek tek onaylayıp geri gönderebiliyor.
### Değişti
### Düzeltildi
### Kaldırıldı
```
Kullanıcıya dönük sürüm notu bunun sadeleştirilmiş, teknik terimsiz özetidir.
