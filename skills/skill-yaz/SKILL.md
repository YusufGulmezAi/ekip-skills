---
name: skill-yaz
description: ekip-skills eklentisine yeni bir skill yazar ya da mevcut skill'i günceller; retro'daki "eklenti için öneri" maddelerini çalışan, doğrulanmış ve eval'le ölçülebilir skill'e çevirir. USE FOR — "yeni skill yaz", "skill ekle", "skill'i güncelle", "eklentiye kural ekle", "write a skill", retro çıktısındaki eklenti önerisi işlenecekken. DO NOT USE FOR — proje kodu yazmak (`uygula`), proje dokümanı (`belgele`), proje kural dosyaları `.claude/rules/` (`kurulum`).
argument-hint: "[skill adı veya retro önerisi]"
---

# Skill yaz

Amaç: eklentinin ekip tarafından büyütülebilmesi. Kötü yazılmış skill iki şekilde zarar verir: yanlış tetiklenir (her oturumda token yakar, yanlış işe karışır) ya da hiç tetiklenmez (var ama yok).

## Kurallar
1. **Tek iş.** Skill tek bir işi yapar; "ve" ile anlatılıyorsa muhtemelen iki skill'dir. Önce çekirdek tabloya bak: mevcut bir skill'in kapsamına giriyorsa yenisini açma, onu güncelle.
2. **Tetiklenmeyi description belirler.** Üçüncü kişi, tek paragraf; **USE FOR** (kullanıcının gerçek söyleyişleri, Türkçe + İngilizce) ve **DO NOT USE FOR** (karışabileceği komşu skill'lere yönlendirme) kalıbı zorunlu. Gövdeye yazılan tetikleme kuralı çalışmaz; model yalnız description'ı görür.
3. **Gövde kısa (20–70 satır).** Sıralı adımlar + gerekçeler; uzun listeler `references/`, çalıştırılabilir işler `scripts/` (betik yoksa elle komut listesi). Okunamama ihtimaline dayanıklı: temel içerik SKILL.md içinde kalır, references süslemedir.
4. **Çekirdekle çakışma kontrolü.** Yeni kural `rules/cekirdek.md` ya da başka skill'le çelişiyorsa önce çelişki çözülür; iki yerde farklı söylenen kural, hiç söylenmemiş kuraldan kötüdür. Çekirdeğe satır eklenecekse hook bütçesi kontrol edilir: çekirdeğin **karakter** sayısı (`python3 -c "print(len(open('rules/cekirdek.md',encoding='utf-8').read()))"`; `wc -c` bayt sayar, Türkçe harf 2 bayt) + durum payı (3.000) + git özeti < 10.000.
5. **Doğrula.** `claude plugin validate .` geçmeli; çekirdek tabloya ve README skill tablosuna satır eklenmeli; akış sayfası varsa sayılar güncellenmeli.
6. **Davranış iddiası eval ister.** "Skill şunu yaptırır" iddiası için `evals/<vaka>/`: gerçekçe bir `prompt.md`, eklentili/eklentisiz iki kol, `graders/` ölçütleri (ölçüt başına tek iddia; hakem dosya görecekse `focus: {source: file}`). Her yeni skill'e bir de **tetiklenmemeli** senaryosu düşün: benzer ama kapsam dışı istekte skill çağrılmamalı.
7. **Sürüm ve teslim.** Yeni skill → MINOR, mevcut skill'de kural düzeltme → PATCH (`plugin.json`). Ölçülmemiş davranış README'de "ölçülmedi" diye işaretlenir; ölçüm sonucu yalanlarsa skill düzeltilir, iddia düşürülmez.

## Retro önerisinden skill'e
`retro` çıktısındaki "eklenti için öneri" maddesi önce sınıflanır: yanlış komut/eşik → mevcut skill'de PATCH; yeni iş türü → yeni skill; kişisel tercih → eklentiye girmez. Öneri üç farklı işte tekrar etmeden yeni skill açma; bir kez olan şey kural değil anıdır.
