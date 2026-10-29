---
name: devam
description: Yeni oturumda kaldığın yerden güvenle devam ettirir; durum dosyasını, git durumunu ve açık planı okur, son doğrulanan adımı yeniden kanıtlar, sonraki adımı önerir. USE FOR — "kaldığımız yerden devam", "nerede kalmıştık", "devam et", "dün ne yapıyorduk", "resume", "continue where we left off", oturum başında durum dosyası varken ilk iş. DO NOT USE FOR — yeni bir iş başlatma (`sorgula`/`planla`), durum dosyasını yazma (bunu `uygula`/`orkestra` ve Stop hook'u yapar).
argument-hint: "[boş | plan dosyası]"
---

# Devam

Amaç: önceki oturumun bıraktığı iddiaya değil, kanıta dayanarak devam etmek. Durum dosyası "test geçti" diyor olabilir; yeni oturumda bunu yeniden görmeden ilerlemek, yarım kalmış ya da bozuk bir işin üstüne inşa etmektir.

## Adımlar
1. **Durumu oku.** `docs/agent/durum.md` (yoksa dur: "durum dosyası yok, hangi işe devam edelim?"), `git status` ve `git log -5 --oneline`, durumda anılan plan dosyası (`docs/planlar/...`) ve plan panosundaki açık görevler.
2. **Tutarlılık kontrolü.** Durum dosyasındaki "commit edilmemiş dosyalar" listesi ile `git status` örtüşüyor mu? Örtüşmüyorsa (kesintiden sonra elle değişiklik, başka dal) farkı kullanıcıya göster, varsayım yapma.
3. **Son adımı yeniden kanıtla.** Durumdaki "son doğrulanan adım" komutunu çalıştır (derleme/test). Geçmiyorsa durum dosyası yanlış ya da kesinti yarım bıraktı: önce bunu düzelt, ilerleme yok.
4. **Sonraki adımı öner.** Durum + plan panosundan tek bir sonraki adım, bitti ölçütüyle; "evet" ile kabul edilecek biçimde sor. Açık sorular varsa önce onları.
5. **Devret.** Onaydan sonra ilgili skill'e geç (`uygula`, `orkestra`, `incele`). Durum dosyasının güncellenmesi o skill'in sorumluluğudur.

## Durum dosyası biçimi (`docs/agent/durum.md`, ≤ 30 satır)
```markdown
# Durum — 2026-10-28 21:40
**Şu an:** G03 Mahal tespit ekranı (docs/planlar/2026-10-28-tespit.md), dal `feat/42-room-inspection`
**Son doğrulanan adım:** kriter kaydetme provider'ı yazıldı; `flutter test test/features/inspection/` 12/12 geçti
**Sonraki adım:** fotoğraf zorunluluğu kuralı + widget testi
**Açık sorular:** "Yok" seçeneği notsuz kaydedilebilir mi? (kullanıcıya soruldu, cevap bekleniyor)
**Commit edilmemiş:** lib/features/inspection/room_provider.dart, test/features/inspection/room_provider_test.dart
```
