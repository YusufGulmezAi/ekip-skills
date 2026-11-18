# `.claude/rules/api.md` şablonu (≤ 60 satır; yalnız HTTP API sunan projede)

Yöntem ve gerekçe: `belgele/references/api-belgeleri.md`. API'si olmayan projede bu dosya yazılmaz; profilde "API: yok (dış API kararıyla kurulur)" satırı kalır.

```markdown
---
paths: ["**/*Endpoints*.cs", "**/Controllers/**", "**/Contract*/**", "**/openapi*", "docs/api/**", "tests/**/*Endpoint*", "tests/**/*Contract*"]
---
# API kuralları: dış ve iç belge, örnekler

## Kitle
- Her uç noktanın kitlesi işaretli: **dış** (bankalar, müşteriler, 3. taraflar) ya da **iç** (ekip istemcileri, işletim). İşaret: <`ApiAudience` metadata | etiket önekleri>; OpenAPI'de `x-kitle`.
- Dış uçlar: <liste ya da yol öneki, ör. `/v1/...` dış kanal>. İç uçlar: <ör. `/api/v1/...`, `/health`, `/version`>.
- İşaretsiz uç, dış belgeye giren iç uç ya da iç belgeye giren dış uç kapsam testinde kırmızı.

## Tanım
- OpenAPI koddan üretilir: <`--emit-openapi` | derleme hedefi> → <commit edilen dosya>; sapma testi <test adı>.
- Her işlemde Türkçe `WithSummary` + `WithDescription`, `Produces<T>`, `ProducesProblem`; hata `ProblemDetails` + `code` + `params`.
- Kimlik doğrulama şeması belgede: <çerez + CSRF başlığı | bearer | imza başlığı>.
- Elle yazılmış dış sözleşme: <yol | yok>. Varsa tanım odur; uçları testte bu sözleşmeyle doğrulanır.

## Örnekler
- Her işlemde en az bir başarı ve bir hata örneği; HTTP ile çağıran entegrasyon testinden yakalanır, elle yazılmaz.
- Yer: <`docs/api/ornekler` | `docs/` insana ayrılmışsa `tests/<Entegrasyon>/ApiOrnekleri`>`/<dis|ic>/<operationId>/<durum>-<kisa-ad>.json`; commit edilir; sapma testi canlı yakalamayla karşılaştırır, `<ORNEK_GUNCELLE=1>` ile yenilenir.
- Değişken değerler maskeli (`<guid>`, `<zaman>`, `<correlationId>`, `<imza>`); çerez, belirteç ve sır yazılmaz. Veri sentetik; test anahtarı "TEST" işaretli.

## Belge ve dışa aktarma
- Üretim: <betik> → `dis.md`, `ic.md` (git dışı) → <proje kitabı bölümü | yalnız Markdown + Scalar (Development/Test)>.
- Word ve PDF yalnız dış belgeden, istenince: <CI işi adı | yayin adımı>; Word `pandoc`, PDF HTML + Chromium/Playwright <ya da ADR'nin seçtiği araç>. Kapak: ürün, kitle, sürüm, commit, tarih. Çıktı depoya girmez.
- Dış uçta kırıcı değişiklik (`oasdiff breaking`) yalnız yeni API sürümüyle; dış belgede "Değişiklikler" bölümü.

## Bitti ölçütü (uç ekleyen/değiştiren her görev)
- Kitle işareti, Türkçe özet, başarı + hata örneği testleri yeşil; kapsam ve sapma testleri yeşil; OpenAPI dosyası ve örnekler aynı commit'te.
```
