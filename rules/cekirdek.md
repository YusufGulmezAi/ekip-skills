# Ekip çalışma kuralları (.NET + Flutter)

Bu ekipte işler `ekip-skills` skill'leriyle yürür. Bir istek aşağıdakilerden birine %1 ihtimalle bile uyuyorsa, cevap vermeden ve dosya okumadan önce o skill çağrılır; "önce bağlam toplayayım" skill kontrolünü atlamanın gerekçesi değildir.

| İş | Skill |
|---|---|
| Projeyi ilk kez hazırlama, proje profili, kural dosyaları | `ekip-skills:kurulum` |
| Önceki oturumdan kaldığı yerden devam | `ekip-skills:devam` |
| Belirsiz istek, kapsam ve karar netleştirme | `ekip-skills:sorgula` |
| Ekran / arayüz tasarımı (web, tablet, telefon) | `ekip-skills:tasarla` |
| İşi dilimlere, görevlere ve dalgalara bölme | `ekip-skills:planla` |
| Planı uzman ajanlarla paralel yürütme | `ekip-skills:orkestra` |
| Kod yazma, değiştirme, düzeltme | `ekip-skills:uygula` |
| Nedeni bilinmeyen hata | `ekip-skills:hata-ayikla` |
| Kod, diff, PR incelemesi; gelen bulgulara yanıt | `ekip-skills:incele` |
| Karar kaydı, rehber, eğitim dokümanı, changelog | `ekip-skills:belgele` |
| Güvenlik ve saldırı testleri, tehdit modeli | `ekip-skills:guvenlik-testi` |
| Sürüm ve mağaza yayını | `ekip-skills:yayin` |
| Biten işten öğrenim çıkarma | `ekip-skills:retro` |
| Eklentiye skill yazma/güncelleme | `ekip-skills:skill-yaz` |

Olağan sıra: kurulum → sorgula → tasarla → planla → (orkestra | uygula) → incele → guvenlik-testi → belgele → yayin → retro. Küçük işte adımlar atlanır; kararlar ve kanıt atlanmaz.

**Proje kuralı önce gelir.** Projenin CLAUDE.md'si, `.claude/rules/` dosyaları, proje profili ve ADR'leri bu dosyayla çelişirse proje kazanır; çelişki raporda bir satırla anılır. Gevşetilemeyen taban: sır commit'e girmez, veri silen işlem onay ister, kanıtsız "bitti" yok.

**Atlanamayan tetikler:** iş birden fazla sahibe (dotnet, flutter, test, belge) ya da 3+ göreve bölünüyorsa `planla`; kod yazılacaksa `uygula` (ya da onu yükleyen geliştirici ajan); rol, kiracı, kimlik veya dosya yükleme kuralı değişiyorsa bitirmeden `guvenlik-testi`; teslimden önce `incele`.

## Dört kural
1. **Kodlamadan önce düşün.** Varsayım yapma; emin olmadığın şeyi söyle. Birden fazla makul yorum varsa en kısa soruyu sor.
2. **Önce sadelik.** Sorunu çözen en az kod. "İleride lazım olur" diye soyutlama ekleme.
3. **Cerrahi değişiklik.** Diff'teki her satır isteğe kadar izlenebilmeli; dokunulmayan satırlar yeniden biçimlendirilmez, dosya baştan yazılmaz. İlgisiz sorunları düzeltmeden rapora yaz. **İstisna — güvenlik:** dokunulan modülde ya da işin dayandığı kodda bulunan açık (kiracı sızıntısı, yetkisiz uç nokta, repoda izlenen sır) "ilgisiz" değildir: raporun en üstünde **Kritik**; kullanıcı işi sonuna kadar yürütmeyi istediyse testle düzeltilir, değilse onay istenir.
4. **Hedefe bağlı yürütme.** Başlamadan "bitti" ölçütünü tek cümleyle yaz; doğrulanana kadar döngüde kal.

## Küçük dosya, tek sorumluluk
Her dosya tek bir şeyi yapar ve kısa kalır. Eşikler (test dosyaları dahil): C# sınıf dosyası ≤ 200 satır, metot ≤ 30; Dart widget dosyası ≤ 150 satır, `build()` ≤ 60; doküman dosyası tek konu ≤ 150 satır; proje `CLAUDE.md` ≤ 60 satır (ayrıntı `.claude/rules/` ve `docs/`). Eşiği aşan dosya "bölünecek" olarak raporlanır, sessizce büyütülmez. Yığına özgü bölme kuralları `.claude/rules/dotnet.md` ve `flutter.md` içindedir.

## Durum her zaman yazılı
Durum dosyası (`docs/agent/durum.md`, profil başka yol verebilir; ≤ 30 satır, proje kuralı başka sınır verebilir) projenin "kaldığımız yer" dosyasıdır: her doğrulanmış adımdan sonra güncellenir, oturum başında otomatik yüklenir, güncel değilse Stop hook'u bitirmeye izin vermez. Gerekçe: kesinti önceden haber vermez; sonda yazılan durum kesintide yazılmamış olur.

## Kanıtsız "bitti" yok
İddiayı kanıtlayan komutu belirle, çalıştır, çıktıyı oku, ancak sonra iddiayı yaz. Çalıştıramadıysan açıkça söyle. Alt ajanın "başardım" raporu kanıt değildir; diff ve komut çıktısı kanıttır. İşin son mesajı şu başlıkları taşır: **Kritik bulgular** (varsa en üstte) · Ne değişti · Kanıt (komut → sonuç) · Çalıştırılamayan · Belge etkisi · Onay bekleyenler.

## Üç deneme kuralı
Aynı hata için üçüncü düzeltme de işe yaramadıysa dur, varsayımı sorgula, kullanıcıya anlat.

## Dil ve bellek
Kullanıcıya Türkçe yaz. **Adlandırma profilde:** varsayılan kod İngilizce, alan terimleri `docs/sozluk.md` eşlemesiyle; profil "Türkçe alan tipleri" diyorsa alan tipleri Türkçe, altyapı tipleri İngilizce. **Kod açıklamaları Türkçe:** her public tür ve üyede Türkçe XML doc (`<summary>`) / dartdoc; bunlar API başvurusu ve eğitim dokümanlarına kaynaklık eder. **Eşleme kütüphanesi yok:** AutoMapper, Mapster, Mapperly vb. kullanılmaz; eşleme ekibin kendi `static` eşleyici sınıflarında, elle ve testli yazılır. Ekip öğrenimleri `docs/agent/ogrenimler.md`'de (git ile paylaşılır); kişisel tercihler Claude'un otomatik belleğinde kalır, repo'ya yazılmaz.

## Yeşilse kaydet
Derleme, biçim/analiz ve projede **var olan** test katmanlarının tamamı bu oturumda çalıştırılıp yeşil olunca iş dalına otomatik commit + push yapılır; sorulmaz. Henüz yazılmamış katman (örn. entegrasyon testi yok) engel değildir ama rapora yazılır. Sınırlar: yalnız iş dalı (`main`/korumalıdaysa önce iş dalı açılır); `git add` yalnız bu işin dosyaları (`-A` yok) ve eklemeden önce sır taraması; test kırmızı veya çalıştırılamadıysa commit/push yok; push reddedilirse rebase/force denemeden dur ve anlat; PR açmak ve `main`'e birleştirmek otomatik değil. Alt ajanlar commit atmaz, teslimi kabul eden ana oturum atar. Gerekçe: kayıt kesintiye karşı sigortadır, ama kırmızı kod paylaşılan dala gitmemeli.

## Token tutumluluğu
Sabit bağlam (CLAUDE.md, kural dosyaları) oturum ortasında değiştirilmez; değişiklikler oturum sonunda toplanır (önbellek bozulmasın). Dilim tek oturumda biter; alakasız yeni işe eski bağlam sürüklenmez — temiz oturum + `devam` daha ucuzdur. 3–5 araç çağrısıyla bitecek işe alt ajan açılmaz. Okuma hedefli: dosyanın tamamı değil, arama + satır aralığı; düzenleme sonrası doğrulama okuması yok. Sır taraması, kanıt komutu, diff okuma, mockup onayı ve var olan testler tasarruf gerekçesiyle atlanmaz: tek bir yeniden yazım hepsinden pahalıdır.

## Onay eşiği
**Sormadan yapılır, raporda bildirilir:** yazım ve metin düzeltmesi, belge güncellemesi, onaylı kararın mekanik uygulaması, test ekleme, davranışı onaylı spesifikasyona geri getiren düzeltme. **Sorulur:** aşağıdakiler, yeni ekran düzeni, entity/şema, ADR değişikliği, kapsam değişikliği.

## Dokunulmazlar
Yeni ekran düzeni onaysız kodlanmaz (onay yüzeyi profilde; varsayılan mockup). Entity ve şema değişikliği onaylı model önerisi (alanlar ve nedenleri, ilişkiler, kısıtlar, kapsam dışı) olmadan yazılmaz. Sır ve bağlantı dizesi koda ve commit'e girmez. Silme, zorla push, `main`'e doğrudan push, veri tabanı sıfırlama, migration uygulama, paket ekleme ve yayın kullanıcı onayı olmadan yapılmaz.
