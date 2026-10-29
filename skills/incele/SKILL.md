---
name: incele
description: Yazılmış .NET (C#) veya Flutter (Dart) kodunu, diff'i, dalı ya da PR'ı gözden geçirir; bulguları öncelik sırasıyla sunar, izinsiz düzeltme yapmaz. USE FOR — "kodu incele", "PR'ı değerlendir", "diff'e bak", "review", "code review", "check this PR", "staged değişiklikleri kontrol et", bir iş bittikten sonra son kontrol; ayrıca gelen inceleme bulgularını ele almak: "bulgular geldi", "inceleme sonuçlarına bak", "reviewer şunları demiş", "address review feedback" (bölüm 3b). DO NOT USE FOR — kod yazma/düzeltme (`uygula`), log veya hata mesajı okuma, genel "şuna bak" istekleri.
argument-hint: "[PR no | dal | dosya | boş = çalışma ağacı]"
allowed-tools: Read Grep Glob Bash(git diff *) Bash(git log *) Bash(git merge-base *) Bash(git grep *) Bash(git ls-files *) Bash(gitleaks *) Bash(gh pr diff *) Bash(gh pr view *)
---

# İncele

Amaç: değişikliği birkaç farklı gözle okuyup kanıtlı, öncelikli bulgular sunmak. Düzeltmek kullanıcının kararıdır: bazı bulgular bilinçli tercihtir, bazıları başka işin konusudur.

## 1. Kapsam
`$ARGUMENTS` değerine göre:
- Boş → `git diff` + `git diff --staged` (commit edilmemiş iş).
- Dal adı → `git diff $(git merge-base HEAD <dal>)...HEAD`.
- PR numarası → `gh pr diff <no>` (ve `gh pr view <no>` ile açıklama).
- Dosya → o dosya, bağlamıyla.
Kapsam belirsizse sor.

**Güvenlik taraması diff ile sınırlı değildir.** Her incelemede ayrıca: (1) depo geneli `git grep -n IgnoreQueryFilters` — karar kaydı olmayan her kullanım bulgu; (2) izlenen dosyalarda sır taraması: `gitleaks detect --no-banner`, yoksa `git grep -nEi '(password|pwd|secret|apikey|api_key|token)\s*[=:]' -- ':!*.md'`; (3) değişikliğin dokunduğu modüldeki diğer uç noktaların yetki ve kiracı kontrolü. Diff dışında bulunanlar **"Önceden var olan Kritik"** başlığıyla raporun en üstüne yazılır; "kapsam dışı" diye küçültülmez. Gerekçe: sızıntı çoğu zaman yeni koda değil, yeni kodun dayandığı eski koda yerleşmiştir.

## 2. İnceleyiciler
Üç liste: **genel** (aşağıda, her zaman), **yığın** (`references/dotnet.md` veya `references/flutter.md`, yalnızca değişen dosyaların yığını), **proje** (`.claude/rules/*.md` ve `docs/agent/ogrenimler.md` varsa). Yığın listesi okunamazsa incelemeyi durdurma: genel ve proje listesiyle devam et, raporda "yığın listesi okunamadı" yaz.

Değişiklik **10 dosyadan veya 400 satırdan büyükse** ve alt ajan kullanabiliyorsan, `ekip-skills:dotnet-reviewer` / `ekip-skills:flutter-reviewer` ajanlarını yığına göre **aynı anda** başlat. Ajan bu skill'i görmez: brife kapsamı (diff komutu veya dosya listesi) ve aşağıdaki listenin ilgili yığın bölümünü metin olarak koy. Her biri yalnızca kendi alanındaki bulguları döndürsün; genel listeyi sen uygula. Daha küçük değişiklikte listeleri kendin sırayla uygula; küçük diff için ajan açmak israftır.

## 3. Birleştir ve sun
Aynı sorunu bildiren bulguları tek satıra indir. Kodda görmediğin, kanıtlayamadığın şüpheleri "Emin olmadıklarım" başlığına ayır. Her bulgu:

**[Öncelik]** `dosya:satır` — sorun (bir cümle). Neden önemli. Önerilen düzeltme.

- **Kritik:** veri kaybı, güvenlik açığı, tenant sızıntısı, çökme, yanlış sonuç.
- **Önemli:** hata riski, performans, bakımı zorlaştıran tasarım.
- **Öneri:** okunabilirlik, isimlendirme, küçük sadeleştirme (eksik `const` buraya).

Sonunda sor: hangileri düzeltilsin? Beğenmediğin ama hatalı olmayan stil tercihlerini yükseltme. Bulgu yoksa "değişiklik gerektiren bir şey yok" de ve neleri kontrol ettiğini bir cümleyle yaz; bir şey bulmuş olmak için bulgu üretme.

## 3b. Bulguya yanıt (bulguları alan taraf için)
Her bulgu önce **doğrulanır** (kod okunarak ya da komutla), sonra karar verilir; savunma refleksiyle reddedilmez, körü körüne de uygulanmaz — inceleyici de yanılabilir. Üç yanıt vardır: **kabul** (düzeltme `uygula` görevine döner), **itiraz** (tek paragraf, kanıtla: hangi satır, hangi test), **erteleme** (ayrı işin konusu; issue/plan kaydıyla). Yanıtsız bulgu kapanmaz; Kritik bulgular yanıtlanmadan iş birleştirilmez.

## Genel kontrol listesi
**Doğruluk** — mantık hatası; sınır durumları (boş, null, sıfır, çok büyük); yutulan istisna; kullanıcıya sızan iç hata ayrıntısı; değişiklik bildirilen amacı gerçekten karşılıyor mu.
**Güvenlik** — koda gömülü sır; doğrulanmamış girdinin sorguya, dosya yoluna, komuta girmesi; yetki kontrolü olmayan uç nokta/ekran; günlüğe yazılan kişisel veri.
**Sadelik ve uyum** — istenenden fazla soyutlama; kullanılmayan kod; projenin isimlendirme/katman düzenine uymayan yeni kod; diff'te ilgisiz dosya.
**Test** — yeni davranış ya da düzeltilen hata için test var mı; test gerçekten bir şey doğruluyor mu (assert'siz, her koşulda geçen, uygulamayı tekrarlayan "totolojik" test).
**Güvenlik testi** — yeni/değişen uç nokta veya ekran için `SecurityTests` / `test/security/` altında senaryo var mı (kiracı sızıntısı, yetkisiz rol, girdi sınırı); yoksa `guvenlik-testi` ile eklenmesi **Önemli** bulgu.
**Belge kayması** — değişen modülü `kapsam:` satırında anan dokümanlar (`docs/**/*.md`) hâlâ doğru mu; yeni uç nokta/ekran için rehber veya karar kaydı gerekiyor mu; public API değiştiyse XML doküman yorumu/dartdoc güncel mi. Bayat doküman **Önemli** sayılır: kullanıcı ona güvenerek yanlış iş yapar.

## Boyut
Değişen her dosya için çekirdek eşiklere bak (C# ≤ 200 satır, Dart widget ≤ 150, metot ≤ 30, `build()` ≤ 60). Aşan dosya **Önemli** bulgu: "bölünecek" ve önerilen bölme.
