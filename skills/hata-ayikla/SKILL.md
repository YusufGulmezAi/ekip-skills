---
name: hata-ayikla
description: Nedeni bilinmeyen bir hatanın kök nedenini sistematik bulur; yeniden üretir, daraltır, tek değişkenli hipotezle test eder, düzeltmeyi önce testle kanıtlar; üç başarısız düzeltmeden sonra durur. USE FOR — "neden çalışmıyor", "hata alıyorum", exception, crash, stack trace, "bazen geçiyor bazen kalıyor", flaky test, üretimde görülen sorun, "debug this", "why is this failing". DO NOT USE FOR — nedeni zaten belli küçük düzeltme (`uygula`), kod incelemesi (`incele`).
argument-hint: "[hata mesajı veya belirti]"
---

# Hata ayıkla

Amaç: belirtiyi değil nedeni düzeltmek. Tahminle yapılan her değişiklik ya hatayı gizler ya da yeni hata ekler; ikisi de sonraki ayıklamayı zorlaştırır.

## Dört adım
1. **Kanıt topla, yeniden üret.** Tam hata mesajı, stack trace, adımlar, ortam (sürüm, cihaz, veri). Sahadan gelen şikâyette hata ekranındaki destek kodunu (correlation ID) iste; sunucu logunda o ID tüm isteği verir. Hatayı yeniden üretemiyorsan düzeltmeye geçme; önce üretmenin yolunu bul. Yeniden üretilemeyen hata için gözlem ekle (log, ölçüm) ve kullanıcıya hangi koşulda tekrar bakılacağını söyle.
2. **Daralt.** Son çalışan durumu bul (`git log`, `git bisect`), girdiyi küçült, katmanları ayır (API mi, istemci mi, veri mi). Hedef: hatanın olduğu en küçük kod parçası.
3. **Hipotez kur, tek değişkenle test et.** Hipotez tek cümle ve yanlışlanabilir olsun ("Kusur listesi boş, çünkü tenant filtresi `IgnoreQueryFilters` olmadan çalışıyor"). Aynı anda tek şey değiştir; birden fazla değişiklik hangisinin işe yaradığını gizler.
4. **Düzelt ve kanıtla.** Hatayı yeniden üreten test yaz, kaldığını gör, düzelt, geçtiğini gör (`uygula` adım 3). Benzer yerlerde aynı hata var mı, ara ve raporla.

## Üç deneme kuralı
Üçüncü düzeltme de işe yaramadıysa dördüncüyü deneme. Dur ve kullanıcıya anlat: denenenler, her birinin sonucu, şu an en olası açıklama. Üç başarısız düzeltme genellikle yanlış katmanda arandığını veya bir varsayımın yanlış olduğunu gösterir.

## Araçlar
Yığına özgü teşhis komutları: `references/araclar.md`.

## Rapor
Belirti → kök neden (tek cümle) → kanıt (komut ve çıktı) → düzeltme → eklenen test → benzer riskli yerler. Kök neden bir varsayım hatasıysa `retro` için not düş.
