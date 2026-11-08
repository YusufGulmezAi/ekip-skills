# ekip-skills

.NET (C#) ve Flutter (Dart) ekipleri için Claude Code çalışma yöntemi: 14 skill, 7 uzman ajan, 3 betik, 2 hook, oturum başı kural enjeksiyonu ve 22 senaryoluk eval seti.

## Akış
```
kurulum → sorgula → tasarla → planla → orkestra | uygula → incele → belgele → yayin → retro
                                          ↑                                              │
                                          └──────── docs/agent/ogrenimler.md ◄───────────┘
```
Küçük işte adımlar atlanır; kararlar ve kanıt atlanmaz.

## Skill'ler
| Skill | Görev |
|---|---|
| `devam` | Yeni oturumda durum dosyası + git + plan okur, son adımı yeniden kanıtlar, sonraki adımı onaya sunar |
| `kurulum` | Proje profili (CLAUDE.md bloğu), doküman haritası, sözlük, öğrenim dosyası |
| `sorgula` | Belirsiz isteği önerili, numaralı sorularla netleştirir; onaysız inşa yok |
| `tasarla` | Web/tablet/telefon ekranları: kullanım bağlamı → pencere sınıfı → kararlar → çizim → koda aktarım notu |
| `planla` | Dikey dilimler, sözleşme önce, sahip/bağımlılık/bitti/belge etkisi, dalgalar |
| `orkestra` | Mimar rolü: planı ajanlara dağıtır, paralel yürütür, her teslimi kendisi doğrular |
| `uygula` | Küçük adım + doğrulama, önce test (yeni davranışta da), yeşilse otomatik commit+push, kanıtlı bitiş raporu |
| `hata-ayikla` | Yeniden üret → daralt → tek değişkenli hipotez → testle düzelt; üç deneme kuralı |
| `incele` | Diff/dal/PR incelemesi, öncelikli bulgular, belge kayması kontrolü |
| `belgele` | Diátaxis: öğretici, nasıl yapılır, başvuru (koddan üretilir), açıklama/ADR; kodla birlikte |
| `guvenlik-testi` | Tehdit modeli → senaryo → otomatik güvenlik testi (SecurityTests, Flutter sır/yetki), CI taramaları; yalnızca kendi sistemler |
| `yayin` | Sürüm, changelog, migration sırası, Docker, Android/iOS paketleri, mağaza, geri dönüş planı |
| `retro` | Biten işten tek satırlık kurallar; üç tekrar eden öğrenim proje kuralına yükselir |
| `skill-yaz` | Eklentiye yeni skill yazar/günceller: USE FOR kalıbı, çekirdek çakışma ve hook bütçesi kontrolü, eval şartı, sürümleme |

## Takım (ajanlar)
| Ajan | Yazar mı | Ön yüklü skill |
|---|---|---|
| `kesifci` | Hayır | — |
| `dotnet-gelistirici` | Evet, brifteki klasörler | `uygula` |
| `flutter-gelistirici` | Evet, brifteki klasörler | `uygula` |
| `test-yazari` | Yalnız test dosyaları; sözleşmeden yazar | — |
| `belge-yazari` | Yalnız `docs/`, `CHANGELOG.md` | `belgele` |
| `dotnet-reviewer`, `flutter-reviewer` | Hayır | — |

Mimar ana oturumdur. Ajanlar başka ajan başlatmaz, kullanıcıya soru soramaz; soruları mimar toplar. Aynı yığında paralel yazan ajanlar `isolation: "worktree"` ile ayrı kopyada çalışır.

**Önemli:** Oturum başı hook'u ile gelen çekirdek kurallar alt ajanlara ulaşmaz (ölçüldü). Bu yüzden yazan ajanların her birinde kısa bir "Çalışma kuralları" bölümü var. Çekirdek kural değişirse `rules/cekirdek.md` ile birlikte `agents/*-gelistirici.md`, `test-yazari.md`, `belge-yazari.md` de güncellenir.

## Türkçe arama: dil kuralı (v0.12)
v0.10–0.11'deki normalleştirme `ı/İ/I → i` ve `ç→c` gibi katlamalar yapıyordu ("isparta" ISPARTA'yı buluyordu). Doğru kural (Yusuf, 6.11.2026): `ı↔I` ve `i↔İ` ayrı harf çiftleri, `ç ş ğ ö ü` ayrı harf, yalnız şapka sadeleşir (`â→a`, `î→i`, `û→u`).
- `TextNormalizer.ForSearch` artık Türkçe küçük harf üretir (`I→ı`, `İ→i`), Türkçe harfleri korur, şapkayı ve ayrışık İ noktasını sadeleştirir; 64 test ICU'lu ve ICU'suz kipte yeşil, kullanıcının arama tablosu test vakası.
- PostgreSQL 16'da ölçüldü: `tr-TR-x-icu` kolon + `ILIKE` harf kuralına uyar, şapkayı sadeleştirmez ("kazım" Kâzım'ı bulmaz); `<Alan>Search` + `LIKE` tablonun tamamını karşılar ve trigram GIN indeksini kullanır.

## Proje kuralları ve profil seçenekleri (v0.11)
Mevcut bir projenin (Akses) kural seti ile karşılaştırmadan çıktı.
- **Proje kuralı önce gelir:** CLAUDE.md, `.claude/rules/`, profil ve ADR'ler eklentiyle çelişirse proje kazanır; gevşetilemeyen taban: sır commit'e girmez, veri silen işlem onaylı, kanıtsız "bitti" yok.
- **Profilde çalışma tercihleri:** adlandırma (İngilizce + sözlük | Türkçe alan tipleri), ekran onayı (önce mockup varsayılan | mockup istendiğinde, onaylı desen + spesifikasyon), çalışma düzeni (tek oturum | mimar + geliştirici), git yetkisi (temkinli | geniş), durum dosyası yolu, geliştirici kabuğu. `kurulum` mevcut projede bunları projenin kendi kurallarından çıkarır.
- **Veri modeli onay kapısı:** entity/şema değişikliği onaylı model önerisi (alanlar ve nedenleri, ilişkiler, kısıtlar, kapsam dışı) olmadan yazılmaz; `planla` ilk görev yapar, `uygula` ve geliştirici ajanı durur.
- **Onay eşiği:** sormadan yapılanlar (yazım, belge, onaylı kararın mekanik uygulaması, test, spesifikasyona geri getiren düzeltme) ve sorulanlar tek listede.
- **Blazor:** `incele/references/blazor-ssr.md` (statik SSR'da sahada yaşanmış form, kültür, DbContext, gelişmiş gezinti tuzakları), `tasarla/references/web-ilkeleri.md` (canlı katalogda bileşen onayı, teker teker inceleme, form yerleşimi sorusu, yerleşik desen istisnası).
- **Veri:** PublicId yalnız dışarıda görünen varlıklarda, kolon `text COLLATE "C"`; aşağı doğru navigation koleksiyonu yok; kırmızı çizgiler mimari testle.
- **Orkestra:** tam test tek yerde (ajan filtreli, mimar bir kez), worktree tabanı, süreç ve commit dersleri.
- **Kanca (v0.12.1):** durum dosyası profildeki "Durum dosyası:" satırından, yoksa `docs/agent/durum.md`, o da yoksa `docs/DURUM.md`. Oturum başı çıktısı ≤ 10.000 karakter: durum sığmazsa önce Sıradaki/Sonraki/Açık başlıklı bölümler, sonra kalan bütçeyle baştan, satır sınırında. Stop kancası yalnız bu oturumda değişen dosyaları sayar (oturum başı işareti `.git/ekip-skills/`), ne profil ne durum dosyası olan projede sessiz kalır, satır sınırını proje kuralına bırakır. Testler: `bash hooks/tests/hooks-test.sh`.
- **Ölçüm (6.11.2026, her vaka 3 koşu × eklentili/eklentisiz, Haiku hakem, ~3,3 USD):** `model-onay` eklentili 0,89 / eklentisiz 0,00 (eklentisiz kol alanları doğrudan entity ve migration'a yazıyor); `mockup-onay` 0,89 / 0,67 (gerileme yok); `proje-kurali-onceligi` 0,89 / 0,89: profil "mockup istendiğinde" dediğinde eklenti kendi varsayılanında ısrar etmeden onaylı desenle sayfayı yazıyor, Türkçe alan tiplerini koruyor; `uygula-tdd` 0,50 / 0,50: bu ortamda .NET SDK olmadığı için kırmızı-yeşil adımları her iki kolda da koşamıyor (v0.10'da 0,25'ti), davranış farkı ölçülemedi.

## Devamlılık: kesinti olsa da kaldığın yerden (v0.6)
Kesinti önceden haber vermez; Claude Code'un `SessionEnd` hook'u çökmede ve terminal kapanınca çalışmaz. Bu yüzden durum işin **içinde** yazılır, sonda değil.
- **`docs/agent/durum.md`** (≤ 30 satır): şu an, son doğrulanan adım + komut, sonraki adım, açık sorular, commit edilmemiş dosyalar. `uygula` her doğrulanmış adımdan, `orkestra` her kabul edilen görevden sonra günceller; `kurulum` iskeletini açar.
- **Stop hook** (`hooks/stop-durum.sh`): çalışma ağacında değişiklik varken durum dosyası eski kalmışsa Claude'u bitirmeden önce durumu yazmaya yönlendirir (döngü koruması: `stop_hook_active` ve 8 ardışık sınırı). Gerçek oturumda doğrulandı.
- **SessionStart hook** (`startup | resume | clear | compact`): çekirdek kurallarla birlikte durum dosyasını ve git özetini (dal, commit edilmemiş dosya sayısı) yükler; sıkıştırma sonrası da geri gelir.
- **`devam` skill'i:** durum × git tutarlılığı, son adımın yeniden kanıtlanması, tek sonraki adım. Gerçek oturumda doğrulandı: doğrulanamayan adımı "geçti" saymadı.
- **Kontrol noktası politikası (v0.7):** derleme + biçim/analiz + var olan test katmanları tüm çözümde yeşilse iş dalına **otomatik commit + push**. Sınırlar: `main`'e doğrudan push yok, zorla push yok, kırmızı veya çalıştırılamayan testle commit yok, `git add -A` yok, sır taraması şart, PR/birleştirme otomatik değil. Alt ajanlar commit atmaz; ana oturum atar. Commit edilmemiş iş kesintide ve worktree'ler arasında kaybolur.
- Oturumun kendisi için Claude Code'un `claude --continue` / `--resume` komutları ve `/rename` ile adlandırma ayrıca kullanılabilir; durum dosyası bunlardan bağımsız, repoda ve ekiple paylaşılır.

## Ekip sabitleri (v0.5)
`kurulum`un ürettiği kural dosyalarında hazır gelir; ekip `<...>` alanlarını doldurur.
- **Dil:** kod daima İngilizce (tür, üye, dosya, tablo); her public üyede **Türkçe** XML doc / dartdoc, API başvurusu ve eğitim dokümanlarını besler. `incele` eksik veya İngilizce açıklamayı bulgu sayar.
- **Eşleme:** AutoMapper, Mapster, Mapperly yasak; `static <Entity>Mapper` uzantı metotları, dosya başına bir eşleyici, testli.
- **Çoklu dil:** .NET `.resx` + `IStringLocalizer<Messages>` ile parametreli mesajlar; Flutter ARB yer tutucuları ve çoğul; API `code`+`params` döner, istemci kendi dilinde üretir; ortak anahtar sözleşmesi `docs/mesajlar.md`.
- **Altyapı** (`.claude/rules/altyapi.md`): korumalı `main` + PR + CI, dal ve commit biçimi, Development|Test|Demo|Production ortamları ve sır yönetimi (user-secrets, `.env.example`, keystore yedeği, "sızan sır ölü sırdır"), bir kez derle–her yerde çalıştır, çok aşamalı Docker imajı + sürüm etiketi, VPS'te SSH-anahtar/ufw/ters vekil/yedek/geri dönüş betiği.
- **Veri kuralları (v0.10, `.claude/rules/veri.md`):** .NET 10 LTS + `global.json`; Türkçe arama normalleştirilmiş `<Alan>Search` sütununda + `pg_trgm` GIN indeksi (ILIKE/nondeterministic collation yok; harf kuralı v0.12'de düzeltildi, aşağıya bakın), Türkçe sıralama ICU `tr-TR-x-icu`; anlar `timestamptz` UTC, tarih filtresi kiracı saat diliminde yarı açık UTC aralığı, gruplama `AT TIME ZONE`; her tabloda `Guid Id` + 10 küçük harfli `PublicId` (kriptografik, benzersiz indeks + CHECK, URL'de yalnız bu). Başvuru kodu `kurulum/references/kod/` (38 test; ICU'lu ve ICU'suz çalışma kipinde yeşil). SQL davranışı PostgreSQL 16 ICU kurulumunda ölçüldü (o günkü yorum ı/i katlamayı doğru sayıyordu; v0.12'de dil kuralına göre düzeltildi) ve trigram indeksi kullanıldı; yerel gün filtresi UTC günüyle 1, yarı açık aralıkla 2 kayıt verdi.
- **Gözlemlenebilirlik ve saha gerçekleri (v0.8):** Serilog + correlation ID (mobil hata ekranındaki "destek kodu" sunucu loguna bağlanır), Sentry/Crashlytics, görsellerde EXIF/GPS temizleme + imzalı URL, deterministik seed (Bogus; Test/Demo'da gerçek veri yasak), CI'da `oasdiff` sözleşme kapısı, `docs/yetki-matrisi.md` tek kaynak, tag tabanlı SemVer + `git-cliff`.
- **Üç test katmanı:** birim, entegrasyon (`WebApplicationFactory` + Testcontainers), güvenlik (`SecurityTests`: kiracı 404, rol 403, kimliksiz 401, girdi 400). `planla` her dilimde üçünü sayar; `guvenlik-testi` senaryo kataloğu verir.
- **Arayüz** (`tasarla`): yapay zekâ üretimi hissi veren hiçbir ekran teslim edilmez (gradyan kahraman, emoji simge, tek tip kart, uydurma istatistik); referans sektörün gerçek uygulamaları ve ürünün kendi verisi. Tartışılacak veya gösterilecek her ekran için önce mockup, kod onaydan sonra. Mobilde küçük bileşenler, yoğun ve dolu ekranlar, canlı ve anlamlı durum renkleri.

## Küçük dosya ilkesi (v0.4)
Her oturumda yüklenen şey küçük kalır; ayrıntı ancak gerektiğinde yüklenir.
- **Proje `CLAUDE.md` ≤ 60 satır** (profil ≤ 40): yalnızca her oturumda gereken gerçekler.
- **`.claude/rules/dotnet.md`, `flutter.md` ≤ 60 satır**, `paths:` ile yalnızca o yığının dosyalarına dokunulunca yüklenir. `kurulum` iskeletini üretir; ekip doldurur.
- **Kod eşikleri:** C# sınıf ≤ 200 / metot ≤ 30 satır; Dart widget ≤ 150 / `build()` ≤ 60. `uygula` eşiği aşan dosyaya eklemek yerine böler; `incele` aşanı Önemli bulgu sayar; `retro` `boyut` etiketiyle izler.
- **Doküman ≤ 150 satır, tek konu;** `belgele` böler ve haritayı günceller.
- **Setin kendisi:** SKILL.md'ler 20–67 satır; yığına özgü listeler `references/` altında (`incele`: dotnet.md, flutter.md); tekrarlı işler betikte (`kurulum/scripts/doktor.sh`, `belgele/scripts/bayat.sh`, `yayin/scripts/surum-kontrol.sh`). Betik okunmaz, çalıştırılır.
- **Model kademesi:** `kesifci` Haiku; inceleyiciler ve `belge-yazari` Sonnet; geliştiriciler oturum modeli; mimar en güçlü model.
- **Bellek ayrımı:** ekip öğrenimi `docs/agent/ogrenimler.md` (git, ≤ 100 satır, üç tekrar → kural); kişisel tercih Claude otomatik belleği (repo dışı); koddan çıkarılabilen bilgi hiçbir yere.

## Dokümantasyon nasıl kendiliğinden güncel kalır
1. `sorgula`, `tasarla`, `planla` kararları "karar kaydı adayı" olarak işaretler → `belgele` ADR'ye çevirir.
2. `planla` her göreve "Belge etkisi" yazar; `uygula` bitiş raporunda bunu doğrular.
3. Başvuru dokümanı (API, sınıflar) koddan üretilir: XML doc + OpenAPI, dartdoc.
4. Her doküman `kapsam:` ve `son_dogrulama:` başlığı taşır; `incele` değişen modülü kapsayan bayat dokümanı **Önemli** bulgu sayar.
5. `yayin` changelog ve kullanıcı sürüm notunu `belgele` ile üretir.

## Kurulum
```
claude plugin marketplace add <org>/ekip-skills
claude plugin install ekip-skills@ekip-skills --scope project
```
Ardından projede: `/ekip-skills:kurulum`. Otomatik güncelleme varsayılan olarak kapalıdır (`/plugin` → Marketplaces). Yeni sürüm için `plugin.json` içindeki `version` artırılır.

Yerel deneme: `claude --plugin-dir /yol/ekip-skills`.

## Doğrulama
```
claude plugin validate .
```
Eval üç kademede çalıştırılır; hakem modeli kademeye göre seçilir. Gerekçe: varsayılan Haiku hakem, transkriptte açıkça bulunan içeriği kaçırıp yanlış "kaldı" verdi (ölçüldü); Opus en tutarlısı ama hakem maliyeti yaklaşık beş kat.

| Kademe | Ne zaman | Komut | Yaklaşık maliyet |
|---|---|---|---|
| Tetiklenme kontrolü | Açıklama (description) değiştirince | `claude plugin eval . --case <ad> --runs 1 --judge-model haiku --trust-plugin --scaffold --allow-tools Write Edit` | < 1 USD / senaryo (yalnızca `tool_used` sonucuna bak) |
| Geliştirme | Skill gövdesi değişince, ilgili senaryolar | `... --case <ad> --runs 2 --judge-model sonnet` | 1–5 USD / senaryo |
| Karar ve sürüm | Oylar bölündüğünde (2-1) ya da sonuç şaşırttığında o senaryo; sürüm öncesi tam set | `... --case <ad> --judge-model opus` · tam set: `claude plugin eval . --runs 2 --judge-model opus --trust-plugin --scaffold --allow-tools Write Edit -j 4` | 2–5 USD / senaryo · tam set 100 USD üzeri |

Ortak bayraklar: `--trust-plugin --scaffold --allow-tools Write Edit --no-publish`. Bash sandbox'ı olmayan makinede `Bash` verilmez; betik gerektiren ölçütler "denendi/çalıştırılamadı" kabul eder. Eklentili ve eklentisiz kol birlikte koşar; `tool_used: Skill` grader'ları tetiklenmeyi, `llm` grader'ları davranışı ölçer. Sonuç `evals/results/<zaman>/report.html`.

### Veri kuralları senaryosu (29.10.2026; .NET 10 + gerçek PostgreSQL, gizli kabul testleri, kör hakem)
Projede `veri.md` ve başvuru sınıfları var, tablolarda henüz PublicId/arama sütunu yok; istek: arama ("isparta" → ISPARTA/Isparta), sitenin yerel günüyle filtre, sıfırlı günlük rapor, kısa bağlantı.
- **Gizli kabul testleri: iki kol da 7/7** (Isparta/ısparta, isik/IZMIR, `%`/`_` kaçışı, İstanbul ve Berlin gece yarısı sınırları, sıfırlı rapor, kısa kodun site dışında 404 olması). İki kol da normalleştirilmiş sütun + trigram GIN, `LocalDateRange`, `char(10)` + UNIQUE + CHECK kurdu. **Sonuç: kurallar ve başvuru kodu "en baştan" projede olunca doğru uygulama eklentiden bağımsız geliyor.**
- **Kör hakem: 12 / 12.** Eklentili kol rapor ve süreçte önde (kanıt komutları, çalıştırılamayanlar, karar kaydı, güncel `durum.md`, `q` uzunluk sınırı); eklentisiz kol kural kapsamında önde (diğer tablolardaki PublicId eksiğini açıkça yazdı, rapor eşlemesi static eşleyicide, merkezî yeniden deneme, daha çok test).
- **Süreç bulgusu:** eklentili kol yalnız `uygula`'yı çağırdı; tek sahipli işte `incele` atlandı ve tam onun yakalayacağı iki kusur kaldı (uç noktada DTO kurulumu, `veri.md` kapsamının sessizce daraltılması).

### Çok sahipli senaryo (29.10.2026, düzeltmelerden sonra; .NET + Flutter gerçek koşu, kör hakem)
Aynı API'ye Flutter uygulaması eklendi; istek "talep iç notları" (backend + mobil + test + belge, paralel). Eski üç tuzak + mobil pakete gömülü anahtar + onay bekleyen tablet varyantı.
- **Sonuç: eklentili 14 / 15, eklentisiz 12,5 / 15** (hakemin hoşgörülü okumasıyla 14,5'e 13,5).
- **Düzeltmeler tuttu:** eklentili kol üç tuzağı da (kiracı sızıntısı, izlenen parola, gömülü anahtar) düzeltti, raporun en üstünde Kritik olarak bildirdi ve kiracı düzeltmesini mutasyonla doğrulanabilen testle korudu; istenmeyen ama gerçek bir açığı da kapattı (sakin `resolve` çağırabiliyordu). Rapor yeni biçimdeydi (Kritik, kanıt tablosu, çalıştırılamayan, belge etkisi, onay bekleyenler); `durum.md` güncel; rehber başlıklı; tablet notundaki açık soru kapatılmadı. Eklentisiz kol tuzakları gördü ama dokunmadı, Kritik demedi, `durum.md`'yi güncellemedi.
- **Süreç:** eklentili kol `planla` (plan dosyası), `orkestra` (dotnet-gelistirici, flutter-gelistirici, test-yazari, belge-yazari + iki inceleyici) ve `guvenlik-testi` çalıştırdı; inceleme bulgusundan ayrı bir düzeltme commit'i çıktı. Eklentisiz kol tek genel ajanla iki dala böldü; dallar birleşince doküman çakışıyor.
- **Eklentili kolun eksikleri:** bir test dosyası 232 satır; varlık eşleyicide değil uç noktada kuruluyor; bir sıralama testi `Task.Delay` kullanıyor; ARB dosyası baştan yeniden biçimlendirilmiş.
- **Maliyet:** eklentili 2,58 USD, eklentisiz 1,27 USD; eklenti işi iki kat pahalıya ama iki kat derin yaptı.

### Kompleks senaryo (29.10.2026, gerçek derleme, kör hakem, ~6 USD)
Derlenen .NET 9 API (çok kiracılı arıza takibi, 9 test), çok parçalı özellik (atama + SLA + iki dilli parametreli mesaj + ekran + rehber + ADR) ve 7 gizli tuzak; eklentili/eklentisiz kol, aynı `CLAUDE.md` ve `.claude/rules/` ile; Opus hakem A/B körlemesine, testleri kendisi koştu.
- **Sonuç: 13,5 / 13,5 — fark yok.** İki kol da derlendi ve yeşil (42 ve 51 test), özelliği tamamladı, `main`'e dokunmadan iş dalını push etti, paket eklemedi, AutoMapper tuzağına düşmedi, onaysız ekran kodu yazmadı, 200 satır sınırını korudu.
- **Yorum:** bu kurallar her iki kolda da proje dosyalarında (`kurulum` çıktısı) vardı; değerin büyük kısmını onlar taşıdı. Eklentinin ayırt edici katkısı belge ve süreç düzeniydi (başlıklı rehber, yetki matrisi, ayrıntılı durum).
- **Eklentili kolun kaybettiği yerler:** mevcut kiracı sızıntısını "ilgisiz sorun, ayrı iş" diyerek düzeltmedi ve Kritik demedi ("cerrahi değişiklik" kuralının yan etkisi); `dotnet-reviewer` yalnız diff'e baktığı için sızıntıyı görmedi; sır taraması yalnız staged diff'te yapıldı, git'te izlenen parola görülmedi; `planla`/`orkestra`/`guvenlik-testi`/`uygula` skill'leri çağrılmadı; onay bekleyen tasarım notundaki açık soruyu kendisi "Karar:" diye kapattı.
- **Yan kazanç:** şablondaki `static class Messages` + `IStringLocalizer<Messages>` kalıbının derlenmediği (CS0718) bu koşuda bulundu ve düzeltildi.
- Tek koşu: eğilim için yeterli, kesin hüküm için değil.

### v0.9 ölçümü (29.10.2026, A+B paketi: 9 eval vakası + 2 gerçek oturum, ~19 USD)
- **Yeşilse kaydet (gerçek oturum, 2 senaryo):** yeşil testte `main`'den iş dalı açıp Conventional commit + yalnız o dalı push etti, `main`'e dokunmadı, `git add` cerrahiydi; kırmızı testte commit/push yapmadı, düzeltme çalışma ağacında kaldı, `durum.md` nedenini yazdı. **İki senaryo da geçti.**
- **Tetiklenme:** `skill-yaz` 1,00 (eklentisiz 0,00); "skill" kelimesi geçen sıradan kod isteği `skill-yaz`'ı tetiklemedi (1,00). `mockup-onay` 0,67/0,00: eklentisiz kol onaysız ekranı kodladı, eklentili kol onay kapısında durdu.
- **Yeniden ölçümler:** `guvenlik-testi` Opus hakemle **1,00/0,67** (tehdit modeli ölçütü artık geçiyor); `planla` 0,67/0,33; `hata-ayikla` 0,75/0,50.
- **Eval'in yakaladığı gerçek boşluk:** "bulguları ele al" isteği `incele`'yi tetiklemiyordu → yönlendirme satırı ve USE FOR eklendi; ikinci koşuda tetiklendi.
- **Ölçülemeyenler / şüpheli hakem:** `uygula-tdd` vakası karar+migration gerektirdiği için ajan (doğru olarak) onaya durdu — vaka kararsız bir görevle yeniden yazılmalı; `incele-bulgu-yanit`'ta trace protokole uyarken Sonnet hakem FAIL verdi (Opus ile yeniden oylanmalı); `kurulum` sandbox'ın `.claude/` yazma yasağı yüzünden eval'de ölçülemiyor, gerçek oturumda doğrulanmalı.

### v0.5 doğrulaması
`guvenlik-testi` senaryosu (Sonnet hakem, tek koşu): skill her koşuda tetiklendi; senaryo→test eşlemesi ve sınır ölçütleri geçti; "rapor tehdit modeliyle başlar" ölçütü iki koşunun birinde kaldı, skill metni sertleştirildi, yeniden ölçülmedi. Dil, eşleme, altyapı, i18n ve mobil ilkeleri kurallara yazıldı; davranış ölçümü yapılmadı.

### v0.4 doğrulaması
`kurulum` senaryosu yeni çıktılarla (kısa profil, kural dosyaları, iskelet, doktor) tek koşuda eklentili 1,00 / eklentisiz 0,00. Eval ortamı `.claude/` altına yazmayı yasakladığı için kural dosyaları orada yalnızca "hazırlandı" olarak doğrulanır; gerçek projede yazılır. Diğer senaryolar v0.4 ile yeniden ölçülmedi.

### Son tam ölçüm (v0.3.0, 28.10.2026, senaryo başına 2 koşu × 2 kol, Sonnet hakem, örnek projeli)
- **Tetiklenme:** 12 skill senaryosunun 24 koşusunun 24'ünde doğru skill çağrıldı; tetiklenmemesi gereken 2 senaryonun 4 koşusunda hiçbiri çağrılmadı.
- **Davranış:** eklentili kol ortalama 0,93, eklentisiz 0,49; fark +0,44. Hiçbir senaryoda eklentili kol geride değil. 14 senaryonun 9'unda eklentili kol tam puan.
- **Kalan boşluklar:** `planla` görevleri davranış yerine katmana göre grupluyordu (skill tanımı düzeltildi, yeniden ölçülmedi); `hata-ayikla` 0,62'de kaldı (ölçütler düzeltildi, yeniden ölçülmedi). Hakem oyları iki ölçütte bölündü (PFP, PPF): iki koşu kesin sonuç için az, eğilim için yeterli.
- **Maliyet:** tam set yaklaşık 63 USD; dört senaryonun yeniden ölçümü 15 USD. Tek senaryo için `--case <ad>`, ucuz deneme için `--runs 1 --judge-model haiku`.

Ölçümlerin bulduğu gerçek hatalar: (1) `incele` kontrol listesini ayrı dosyadan okuyamayınca tamamen duruyordu; temel içerik SKILL.md'ye taşındı. (2) `planla`'nın "dikey dilim" tanımı sahip bazlı görevlerle çelişiyordu; dilim = davranış, görev = dilim içinde sahip olarak yeniden tanımlandı. (3) `yayin` "yapılmadı" dediği adımın komutunu göstermiyordu; eksiksiz komut şartı eklendi.

## Bilinçli olarak dışarıda bırakılanlar
- Ekibin kendi mimari, isimlendirme, state management ve test çerçevesi kuralları: `kurulum` bunları proje profiline yazar; eklentiye gömülmez.
- Claude Code'un deneysel "agent teams" özelliği: kapalı varsayılan, üyeler `skills` alanını uygulamıyor, aynı dosyayı düzenleyen iki üye birbirini eziyor. Olgunlaşınca değerlendirilecek.
