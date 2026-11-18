# `.claude/rules/api.md` şablonu (≤ 60 satır; yalnız HTTP API sunan projede)

Yöntem ve gerekçe: `belgele/references/api-belgeleri.md` (güvenlik ve kurulum), `api-belge-yapisi.md` (bölümler, dizinler, açıklamalı örnek). API'si olmayan projede bu dosya yazılmaz; profilde "API: yok (dış API kararıyla kurulur)" satırı kalır.

```markdown
---
paths: ["**/*Endpoints*.cs", "**/Controllers/**", "**/Contract*/**", "**/openapi*", "docs/api/**", "tests/**/*Endpoint*", "tests/**/*Contract*", "tests/**/ApiExamples/**"]
---
# API kuralları: dış ve iç belge, örnekler, güvenlik

## Kitle ve kimlik
- Her uçta kalıcı `operationId` (`WithName("<Resource>_<Action>")`) ve kitle metadata'sı `ApiAudience.External | Internal` (OpenAPI'de `x-audience`). Etiketle kitle verilmez.
- Dış: <bankalar, müşteriler, 3. taraflar; ör. `/v1/...`>. İç: <ör. `/api/v1/...`, `/health`, `/version`>.
- Kapsam testi uçları `EndpointDataSource`'tan gezer (OpenAPI dışı uçlar dahil): işaretsiz uç, dış belgede iç uç, iç belgede dış uç → kırmızı.

## Tanım
- İç belge <ad> ve dış belge `external` ayrı adlandırılmış OpenAPI belgeleri; commit edilir, sapma testi <test adı>. Bayrakla açılan üretim kipi yok.
- Her işlemde Türkçe `WithSummary` + `WithDescription`, `Produces<T>`, `ProducesProblem`; hata `ProblemDetails` + `code` + `params`; kimlik şeması <çerez + CSRF | bearer | imza başlığı>.
- Elle yazılmış dış sözleşme: <yol | yok>; alan listesinin kaynağı: <belge/blok>; testte yanıtla karşılaştırılır.

## Örnekler
- Her uçta ≥ 1 başarı + ≥ 1 hata örneği, entegrasyon testinden; istisnalar adıyla testte: <`Health_Live`, `Version_Get`>.
- Yer: `<tests/.../ApiExamples>/<external|internal>/<operationId>/<status>-<short-name>.json` + aynı adla açıklama dosyası (senaryo, ne zaman, alan açıklamaları, hata için istemci ne yapmalı). Açıklamasız örnek ya da örnekte olmayan alanı açıklayan not → kırmızı.
- Maske **izin listesiyle**: listede olmayan başlık ve alan yazılmaz; değişken değerler yer tutucu. Veri sentetik.

## Güvenlik
- Yayımlanan test anahtarı canlıda reddedilir; bekçi testi: <test adı>.
- Belgelenen her hata cevabı, yetkisi olmayana kaydın varlığını söylemez (başkasının kaydı = olmayan kayıt).
- Dış paket (PDF, DOCX, Postman, dış OpenAPI) metne çevrilip sır, iç yol/başlık/ana makine ve `localhost` için taranır.
- Postman: `{{baseUrl}}` yer tutucu, anahtar değişkenleri boş ve `secret` tipli, istek öncesi betikte `console.log` yok (testle). Dış OpenAPI `servers` yer tutucu. Dış kapakta commit yok.

## Belge ve dışa aktarma
- Bölüm şablonu ve üç dizin (uç, hata kodu, alan) `api-belge-yapisi.md`'deki gibi; hata kodu kaydı <`ApiErrorCodes`> ve dış alanlar dizinle testte eşleşir.
- Araçlar (onaylı, sürüm sabit): <pandoc x.y | docfx pdf | Chromium> · <newman x.y>. Üretim: <betik> → <proje kitabı bölümü | Markdown>; Word/PDF, Postman v2.1 + ortam (birincil), dış OpenAPI 3 (ikincil) istenince <CI işi | yayin>. CI'da Newman test ortamına karşı yeşil. Çıktı depoya girmez.
- Dış uçta kırıcı değişiklik (`oasdiff breaking`) yalnız yeni API sürümüyle.

## Bitti ölçütü (uç ekleyen/değiştiren her görev)
- `operationId`, kitle, Türkçe özet, açıklamalı başarı + hata örneği, dizin satırları; kapsam, sapma, dizin ve güvenlik testleri yeşil; OpenAPI belgeleri ve örnekler aynı commit'te; dış uçta Newman yeşil.
```
