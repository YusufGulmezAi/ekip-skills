---
name: orkestra
description: Onaylanmış bir planı mimar rolünde yürütür; görevleri dalgalar halinde uzman ajanlara (dotnet-gelistirici, flutter-gelistirici, test-yazari, belge-yazari) dağıtır, birbirine dokunmayanları paralel çalıştırır, her teslimi diff ve komutla kendisi doğrular, birleştirir ve plan dosyasında durumu tutar. USE FOR — "orkestra", "takımla yap", "ajanlara dağıt", "paralel geliştir", "planı yürüt", "run the plan", "use the team", planda 3+ görev ve birden fazla sahip olduğunda. DO NOT USE FOR — planı olmayan iş (önce `planla`), tek görevli veya tek dosyalık iş (`uygula`).
argument-hint: "[plan dosyası, örn. docs/planlar/2026-10-28-onay-akisi.md]"
---

# Orkestra

Ana oturum **mimardır**, ajanlar **uzmandır**. Mimar kod yazmaz: işi böler, brifler, teslimi doğrular, birleştirir ve kullanıcıyla konuşur. Gerekçe: ajanlar konuşma geçmişini görmez ve kullanıcıya soru soramaz; büyük resmi ve kullanıcıyla bağı yalnızca ana oturum taşır.

## Takım
| Ajan | İş | Yazar mı |
|---|---|---|
| `ekip-skills:kesifci` | Kod tabanında soru cevaplar, özet döndürür | Hayır |
| `ekip-skills:dotnet-gelistirici` | .NET görevleri | Evet |
| `ekip-skills:flutter-gelistirici` | Flutter görevleri | Evet |
| `ekip-skills:test-yazari` | Sözleşmeden kabul ve entegrasyon testleri | Yalnız test dosyaları |
| `ekip-skills:belge-yazari` | Rehber, karar kaydı, changelog | Yalnız `docs/` ve `CHANGELOG.md` |
| `ekip-skills:dotnet-reviewer`, `ekip-skills:flutter-reviewer` | Taze gözle inceleme | Hayır |

Model kademesi: keşifçi Haiku, inceleyiciler ve belge yazarı Sonnet, geliştiriciler ve test yazarı oturumun modeli; mimar en güçlü modelde kalır. Gerekçe: toplam maliyetin çoğu ajanlarda birikir, ucuz iş ucuz modele.

Yapı düzdür: ajanlar başka ajan başlatmaz. Claude Code iç içe delegasyona izin verse de, hangi değişikliği kimin yaptığı izlenemez hale gelir.

## 1. Hazırlık
1. Plan dosyasını oku. Yoksa dur ve `planla`'ya dön.
2. **Soruları şimdi topla.** Ajanlar kullanıcıya soramaz; planı tara, ajanın takılacağı belirsizlikleri (sözleşme alanı, iş kuralı, adlandırma) tek turda kullanıcıya sor, cevapları brife koy.
3. Çalışma ağacı temiz mi (`git status`)? Değilse kullanıcıya sor; kirli ağaçta ajan değişikliği ayırt edilemez.
4. Dalgaları, kritik yolu ve kaç ajanın aynı anda çalışacağını göster; onay al.

## 2. Dalga yürütme
- **Aynı anda en fazla 4 yazan ajan.** Daha fazlası birleştirme çakışmasını ve maliyeti hızlandığından çok artırır.
- **Yalıtım:**
  - Farklı yığın ve ayrık klasörler (bir .NET + bir Flutter ajanı) → aynı çalışma ağacı.
  - Aynı yığında iki yazan ajan ya da aynı projeye/migration'a dokunan iki görev → her birine Agent çağrısında `isolation: "worktree"`. Worktree varsayılan olarak ana daldan açılır, mevcut HEAD'den değil: önceki dalgalar commit edilip ana dala alınmış olmalı (ya da projede worktree tabanı HEAD olarak ayarlanmış olmalı).
  - Emin değilsen sırala; yanlış paralellik, kazandırdığından fazla zaman kaybettirir.
- **Brif:** ajan yalnızca brifi bilir; brifte olmayan bağlam yoktur. Her brifte beş başlık: **Görev** (plan satırı ve plan dosyası), **Bitti ölçütü** (kanıtlayan komutla), **Bağlam** (sözleşme, ilgili kararlar, kullanıcıdan alınan cevaplar, tasarım notu), **Sınırlar** (dokunabileceği ve dokunmayacağı klasörler; commit yok), **Dönüş biçimi** (değişen dosyalar, kanıt, çalıştırılamayanlar, açık sorular, belge etkisi). Doldurulmuş örnek: `references/brif-sablonu.md`.
- Dalgadaki ajanları aynı mesajda başlat.

## 3. Teslim: güven ama doğrula
Her dönüşte, ajanın raporundan bağımsız olarak:
1. **Diff'i oku.** Rapor ile diff uyuşmuyorsa teslim reddedilir.
2. **Kanıtı kendin üret.** Görevin bitti ölçütünü kanıtlayan komutu ana oturumda çalıştır.
3. **Kapsam:** brifte izin verilen klasörlerin dışına çıkılmış mı?
4. **Soru döndüyse:** kullanıcıya sor, cevabı aynı ajana ilet.
5. **Kabul:** worktree ise dalı birleştir; etkilenen çözümü derle ve test et; plan dosyasında görevi işaretle ve `docs/agent/durum.md`'yi güncelle (hangi dalga, hangi görevler kabul edildi, hangileri açık, açık sorular).
6. **Ret:** gerekçeyle aynı ajana bir kez geri gönder. İkinci başarısızlıkta dur, kullanıcıya getir.

## 4. Dalga sonu
- Backend ve mobil için tam derleme ve test. Hepsi yeşilse mimar (ana oturum) iş dalına commit + push eder (çekirdek "Yeşilse kaydet"); ajanlar commit atmaz.
- Sözleşme kontrolü: API yanıtı ile Dart modeli aynı alanları taşıyor mu.
- Dalgada 10+ dosya değiştiyse inceleyicileri taze bağlamla çalıştır. **Kritik bulgu varken sonraki dalga başlamaz.**

## 5. Kapanış
1. Tüm iş için `incele`.
2. Görevlerdeki "Belge" satırlarını toplayıp `belge-yazari`'ya ver; sonucu doğrula.
3. **Dalı kapat.** Birleşen worktree'ler kaldırılır (`git worktree remove`, sonra `git worktree prune`); `main`'e PR kullanıcı kararıyla açılır; birleşen iş dalının silinmesi için onay istenir. Plan dosyası "tamamlandı" işaretlenir, `docs/agent/durum.md` "Şu an: iş yok"a döner. Gerekçe: kapanmamış dal ve worktree, bir sonraki işin kirli zeminidir.
4. Kullanıcıya rapor: görev tablosu (durum, ajan, kanıt), açık sorular, retro için gözlemler (geri gönderilen teslimler, çakışmalar).

## Durum panosu
Plan dosyası tek doğruluk kaynağıdır; her kabul edilen görev satırı güncellenir:
```
- [x] G03 [P] [sahip: flutter] Mahal tespit ekranı — tamam · flutter-gelistirici · 28.10 15:40 · flutter test 42/42 geçti
- [ ] G04 [sahip: dotnet] Onay uç noktası — geri gönderildi (1/2): tenant filtresi eksik
```

## Ajan takımları (deneysel)
Claude Code'un deneysel "agent teams" özelliğinde üyeler birbirine mesaj atabilir, ama özellik varsayılan olarak kapalıdır, üyeler `skills` alanını uygulamaz ve aynı dosyayı düzenleyen iki üye birbirinin işini ezer. Bu skill bu nedenle alt ajanlarla çalışır.
