# Ajan brif şablonu

Ajan konuşmayı görmez; brif onun tek bağlamıdır. Eksik brif, ajanın tahmin etmesine yol açar. Her başlığı doldur; boş kalan başlık "yok" yazılır.

```markdown
## Görev
G03 — Mahal tespit ekranı, kriter durumu kaydetme
Plan: docs/planlar/2026-10-28-tespit.md

## Bitti ölçütü
Sorunlu kriter fotoğrafsız kaydedilemez; `flutter test test/features/tespit/` geçer; `flutter analyze` temiz.

## Bağlam
- Sözleşme: `api/openapi.yaml` içindeki `PUT /tespitler/{id}/kriterler/{kriterId}` (G01'de sabitlendi)
- Kararlar: docs/kararlar/0003-kusur-duzeyinde-akis.md
- Kullanıcıdan alınan cevaplar: "Yok" seçeneği notsuz kaydedilebilir.
- Proje kuralları: profilin çalışma tercihleri (adlandırma dili, ekran onayı) ve ilgili `.claude/rules/` maddeleri; eklenti varsayılanıyla çelişirse bunlar geçerli.
- Veri modeli: entity/şema görevi ise onaylı model önerisinin yeri (yoksa görev briflenmez).
- Tasarım: tuvaldeki "Telefon · Mahal tespiti" ekranı; koda aktarım notu aşağıda. Onay: <kişi>, <tarih> (onaysız mockup brife girmez).

## Sınırlar
- Dokunabileceğin yerler: `mobile/lib/features/tespit/`, `mobile/test/features/tespit/`
- Dokunmayacakların: başka feature klasörleri, `pubspec.yaml` (paket gerekiyorsa dur ve sor), backend.
- Commit atma; mimar birleştirir.

## Dönüş biçimi
1. Değişen dosyalar
2. Kanıt: çalıştırdığın komutlar ve çıktıları (sayılarla)
3. Çalıştıramadıkların ve nedeni
4. Açık sorular: karar vermek yerine durduğun yerler
5. Belge etkisi
```
