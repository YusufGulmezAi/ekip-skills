---
name: retro
description: Biten bir işten (özellik, hata düzeltme, PR) somut öğrenimleri çıkarır; ekip öğrenimlerini `docs/agent/ogrenimler.md`'ye yazar, kişisel tercihleri Claude'un otomatik belleğine bırakır, üç kez tekrar edeni kurala yükseltir. USE FOR — "retro yapalım", "bu işten ne öğrendik", "retrospective", "lessons learned", PR birleştikten veya hata çözüldükten sonra, Claude aynı konuda ikinci kez düzeltildiğinde. DO NOT USE FOR — kod yazma (`uygula`), kod inceleme (`incele`), bitmemiş iş.
argument-hint: "[biten iş: PR no, dal veya kısa açıklama]"
---

# Retro

Amaç: her işin bir sonraki işi kolaylaştırması. Yazılmayan öğrenim tekrar eder; yanlış yere yazılan öğrenim ya ekibe ulaşmaz ya da her oturumda boşuna token yakar.

## Adımlar
1. **Kaynağı topla.** Diff (`git log`/`gh pr view`), inceleme bulguları, kullanıcının bu işte yaptığı düzeltmeler. Ara: yanlış çıkan varsayım, ikinci kez söylenen kural, üçüncü denemede çözülen hata, kapsam dışına taşan değişiklik, eşik aşan dosya.
2. **Somutlaştır.** Her öğrenim tek satır: `- [tarih] [etiket] Durum → Kural. (kaynak: PR/commit)`. "Daha dikkatli ol" değil; bir sonraki sefer kodda veya süreçte neyin farklı yapılacağı. Etiketler: `varsayim`, `desen`, `test`, `guvenlik`, `arac`, `alan`, `boyut`.
3. **Yere göre ayır.**
   - **Ekip öğrenimi** (kod, süreç, alan bilgisi) → `docs/agent/ogrenimler.md`. Git ile paylaşılır; `sorgula`, `uygula`, `incele` ve geliştirici ajanlar okur.
   - **Kişisel tercih** (kullanıcının çalışma biçimi, iletişim tercihi) → repo'ya yazma; Claude'un otomatik belleği bunu kendisi tutar. Raporda "kişisel, belleğe bırakıldı" de.
   - **Koddan çıkarılabilen bilgi** (dosya yolu, mimari) → hiçbir yere; kod zaten söylüyor.
4. **Birleştir, yükselt, buda.** Aynı kuralı söyleyen satır varsa yenisini ekleme, var olanı güncelle ve kaynakları birleştir. Bir öğrenim üç farklı işte tekrar ettiyse artık kuraldır: ilgili `.claude/rules/dotnet.md` / `flutter.md` dosyasına (yığına özgüyse) ya da `CLAUDE.md` profiline (genelse) taşınmasını öner, öğrenim satırını sil. Dosya 100 satırı geçince en eski ve geçersizleri kullanıcıyla ele.
5. **Maliyet satırı.** İşin yaklaşık maliyetini yaz (`/cost` çıktısı ya da oturum sayısı × model); pahalı bir desen (yeniden yazım, gereksiz tam-dosya okuma, 3-5 çağrılık işe ajan) üç işte tekrar ettiyse `boyut`/`arac` etiketiyle kurala yükselt.
6. **Eklenti için öneri.** Yanlış komut, eksik kontrol maddesi, yanlış tetiklenen skill gibi bulguları "eklenti için öneri" başlığında ayrıca yaz.

## Örnek
- 2026-10-28 `guvenlik` Taşeron listesi `IgnoreQueryFilters` ile başka firmayı gösterdi → kiracı filtresini atlayan sorgu karar kaydı ister; her kiracılı uç noktaya "başka firma 404" testi. (kaynak: PR #31, #37)
- 2026-10-28 `boyut` `KusurEndpoints.cs` 260 satıra çıktı → onay ve atama uç noktaları `KusurOnayEndpoints.cs`'e ayrıldı; kaynak başına 8+ uç noktada böl. (kaynak: PR #37)
