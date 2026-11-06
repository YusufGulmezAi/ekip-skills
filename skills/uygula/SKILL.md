---
name: uygula
description: .NET (C#) ve Flutter (Dart) kodunu küçük adımlarla yazar, değiştirir veya düzeltir; her adımı derleme/analiz/test ile doğrular ve "bitti" demeden kanıt sunar. USE FOR — kod ekleme, değiştirme, hata düzeltme, refactor; "ekle", "düzelt", "yaz", "çalışmıyor", "refactor et", "implement", "fix", "add", "bug" gibi istekler, kullanıcı test ya da doğrulamadan söz etmese bile. DO NOT USE FOR — yazılmış kodu değerlendirme ve gelen inceleme bulgularını ele alma (`incele`; bulgular önce orada doğrulanır, kabul edilen düzeltme buraya döner), kapsamı belirsiz fikirler (`sorgula`), yalnızca açıklama isteyen sorular.
argument-hint: "[yapılacak iş]"
---

# Uygula

Çekirdek kurallar (dört kural, kanıt şartı, üç deneme kuralı) zaten bağlamdadır; burada yalnızca bu skill'in eklediği üç şey var: doğrulama komutları, hata düzeltmede önce test, bitiş raporu.

## Akış
1. **Bitti ölçütü** tek cümle. İstek belirsizse ve cevap sonucu değiştirecekse `sorgula`'ya geç. İş birden fazla katmana (API + mobil) dokunuyorsa önce `planla`; nedeni bilinmeyen hata ise `hata-ayikla`.
2. **Onay şartı: ekran ve veri modeli.** Ekran işinde profildeki onay yüzeyine bak (varsayılan mockup): `tasarla` aktarım notundaki `Onay:` satırı "bekliyor" ise ya da not yoksa kodlama, onayı hatırlat ve dur. Profil "mockup istendiğinde" diyorsa onaylı desen ve spesifikasyon maddesi (atfıyla) yeterlidir; yeni düzen yine sorulur. Entity, şema ya da migration gerektiren görevde onaylı model önerisi (alanlar ve nedenleri, ilişkiler, kısıtlar, kapsam dışı) yoksa öneriyi yaz, onay iste, dur. Onay varsa birebir uy; sapma gerekiyorsa açık soru.
3. **Mevcut deseni oku.** Varsa `docs/agent/ogrenimler.md` (geçmiş işlerden çıkarılan kurallar), değişecek yerin çevresi, aynı işi yapan başka kod, test düzeni. Yeni kod bunlara uysun; proje CLAUDE.md'sindeki komut ve düzen kuralları bu dosyadakilerin önüne geçer.
4. **Önce test — yeni davranışta da.** Yeni davranış: beklenen davranışı tanımlayan testi yaz, **kaldığını gör**, sonra kodla (kırmızı-yeşil; kalmayan test hiçbir şey kanıtlamaz). Hata düzeltme: hatayı yeniden üreten testi yaz, kaldığını gör, sonra düzelt. İstisna gerekçeyle raporlanır: UI/platform/yapılandırma kodu, keşif amaçlı deneme (spike — sonunda ya silinir ya testle yeniden yazılır); bu durumlarda elle doğrulama adımı ver.
5. **Küçük dosya.** Dokunduğun dosya eşiği aşıyorsa (C# ≤ 200, Dart widget ≤ 150 satır; `.claude/rules/` ayrıntı verir) yeni kodu oraya eklemek yerine bölünmüş yeni dosyaya yaz ve bölmeyi raporda belirt. Gerekçe: büyüyen dosya her okunuşta daha çok token ister ve paralel işte çakışma noktası olur.
6. **Küçük adımlar, her adımda doğrulama.** Yalnızca etkilenen projeyi derle (`dotnet build src/X/X.csproj`); tüm çözümü sonunda. Hata çıkarsa mesajı oku, kök nedeni bul; tahminle değiştirme. **Her doğrulanmış adımdan sonra `docs/agent/durum.md`'yi güncelle** (şu an, son doğrulanan adım + komut, sonraki adım, açık sorular, commit edilmemiş dosyalar; ≤ 30 satır). Gerekçe: oturum her an kesilebilir; durum yalnızca sonda yazılırsa kesintide kaybolur. Stop hook'u güncel olmayan durumla bitirmeye izin vermez.
7. **Kendi diff'ini incele (atlanmaz).** Commit'ten önce `git diff` üzerinde `incele`'nin genel listesini ve yığın listesini kendin uygula; ayrıca proje kurallarının (`.claude/rules/*.md`) **kapsamını** kontrol et: kural bu işte yalnız bir kısmına uygulandıysa (ör. PublicId yalnız bir tabloda) kalanı raporda "kural borcu" olarak listele, sessizce daraltma. Kritik ve Önemli bulgu ya düzeltilir ya raporda gerekçesiyle durur. Gerekçe: tek sahipli işte ayrı `incele` çağrısı atlanabiliyor; bu adım `uygula`'nın içinde olduğu için atlanamaz. İş büyükse (10+ dosya) ya da güvenlik dokunuyorsa ayrıca `incele` çağır.
8. **Yeşilse kaydet (otomatik commit + push).** Derleme, biçim/analiz ve projede **var olan** test katmanları **tüm çözümde** (`dotnet test`, `flutter test`; yalnız etkilenen proje değil) bu oturumda çalıştı ve yeşilse, sormadan: `docs/agent/durum.md`'yi güncelle → `git branch --show-current` (`main`/korumalıysa `git switch -c <tür>/<no>-<ad>`) → yalnız bu işin dosyalarını `git add <yol>` (`-A` yok) → sır taraması (`gitleaks protect --staged`; yoksa `git diff --staged` içinde anahtar/bağlantı dizesi kalıpları; bu yalnız değişikliği tarar — raporda "staged tarandı" de, depo geneli `incele`/`guvenlik-testi` işidir) → Conventional Commits mesajıyla commit → `git push -u origin <dal>`. Herhangi bir test kırmızıysa ya da var olan bir katman çalıştırılamadıysa commit/push yok, rapora nedeni yaz; henüz yazılmamış katman engel değildir ama raporda belirtilir. Push reddedilirse rebase/force deneme, durumu anlat. PR açmak kullanıcı kararıdır. Gerekçe: yeşil kod kesintiye karşı uzakta güvende olur; kırmızı kod paylaşılan dala gitmez.
9. **Bitiş raporu** (aşağıda); "Kanıt"a commit hash'i ve push sonucunu, "Kural borcu"na 7. adımda bulunanları ekle.

## Doğrulama komutları
Projenin kendi komutu (Makefile, betik, CI, CLAUDE.md) varsa onu kullan. Yoksa:

**.NET**
- Derleme: `dotnet build` (ilk seferde restore'u kendisi yapar). Yeni uyarı aramak için `dotnet build --no-incremental`; artımlı derleme güncel projelerin uyarılarını gizler.
- Test: `dotnet test`. Tek test: `dotnet test --filter "FullyQualifiedName~Ad"` (VSTest modu). `global.json` içinde `test.runner: Microsoft.Testing.Platform` varsa filtre çerçeveye göre değişir (xUnit v3: `--filter-method`/`--filter-class`; proje `--project` ile verilir). Filtrenin uygulandığını çalışan test sayısından doğrula.
- Biçim: `dotnet format --verify-no-changes`.

**Flutter**
- Analiz: `flutter analyze` (info ve warning'ler varsayılan olarak hata sayılır).
- Test: `flutter test`; tek dosya `flutter test test/yol_test.dart`; tek test `--plain-name "ad"`.
- Kod üretimi (`*.g.dart`, `*.freezed.dart` varsa, model/provider değiştiyse testten önce): `dart run build_runner build` (`--delete-conflicting-outputs` artık varsayılan).
- Biçim kontrolü: `dart format --output=none --set-exit-if-changed .` (`--output=none` olmazsa dosyaları yeniden yazar).

Üretilmiş dosyaları (`*.g.dart`, `*.freezed.dart`, EF migration snapshot) elle düzenleme; üreticiyi çalıştır.

## Bitiş raporu
- **Ne değişti:** dosyalar ve bir cümle.
- **Kanıt:** çalıştırılan komutlar ve sonuçları (geçti/kaldı, sayılar).
- **Çalıştırılamayan:** doğrulayamadığın her şey ve nedeni; kullanıcının çalıştırması gereken komut.
- **Dokunmadıklarım:** fark edilen ama kapsam dışı sorunlar.
- **Yerelde bak (gerekiyorsa):** kullanıcının kendi makinesinde bakması gereken işte profildeki kabukta (Windows'ta PowerShell) kopyala-çalıştır tek blok: dalı al → servisleri adıyla başlat → migration (adı ve "veri silmez" notu) → uygulamayı başlat; ardından bakılacak adresler tablosu.
- **Kural borcu:** proje kuralının bu işte uygulanmadığı yerler (hangi kural, hangi dosya/tablo, neden); yoksa "yok".
- **Belge etkisi:** bu değişiklik hangi dokümanı bayatlattı ya da yeni doküman gerektiriyor (karar kaydı, kullanıcı rehberi, API başvurusu); yoksa "yok". Doluysa `belgele` bir sonraki adımdır. Gerekçe: doküman, kodu değiştiren kişi davranışı henüz hatırlarken en ucuza yazılır.
