# `.claude/rules/altyapi.md` şablonu (≤ 60 satır)

```markdown
---
paths: ["**/Dockerfile*", "**/docker-compose*.y*ml", "**/compose*.y*ml", ".github/**", "deploy/**", "scripts/**", "**/appsettings*.json", "**/.env*", "**/*.sh"]
---
# Altyapı kuralları: GitHub, Docker, VPS, ortamlar

## GitHub
- Dallar: `main` korumalı (doğrudan push yok, PR + 1 onay + CI yeşil); iş dalları `<tür>/<issue-no>-<kisa-ad>` (`feat/42-defect-assignment`, `fix/57-tenant-filter`).
- Commit: Conventional Commits, İngilizce başlık, gövde Türkçe serbest: `feat(defects): add contractor assignment`. İş dalında her doğrulanmış adım küçük bir commit olabilir (`wip:` öneki serbest); `main`'e birleştirirken squash. Birleşen iş dalı onayla silinir, worktree kaldırılır, `durum.md` "iş yok"a döner. Gerekçe: commit edilmemiş iş kesintide kaybolur, worktree'ler arası taşınamaz; kapanmamış dal birikir.
- Otomatik kayıt: derleme + biçim/analiz + var olan test katmanları tüm çözümde yeşilse iş dalına otomatik commit + push (`uygula` 8, öncesinde 7. adımdaki öz-inceleme); `main`'e doğrudan push, zorla push ve kırmızı testle push yok. `main`'e yalnız PR ile girilir.
- PR şablonu `.github/PULL_REQUEST_TEMPLATE.md`: amaç, bitti ölçütü, kanıt (komut çıktısı), belge etkisi, güvenlik etkisi. `incele` bulguları kapanmadan birleştirilmez.
- CI (`.github/workflows/`): her PR'da derleme, üç test katmanı, `dotnet format --verify-no-changes`, `flutter analyze`, `dotnet list package --vulnerable`, sözleşme kayması `oasdiff breaking <son-tag> <şimdi>` (kırıcı fark MAJOR artışı olmadan kırmızı); `main`'de ek olarak imaj üretimi. Sırlar yalnızca GitHub Secrets / Environments; workflow dosyasında düz metin yok.
- Etiketler: `bug`, `feature`, `tech-debt`, `security`, `docs`; `CODEOWNERS` ile `src/**` ve `.claude/**` sahipleri.

## Ortamlar ve sırlar
- Sabit ortam adları: <Development | Test | Demo | Production> (`ASPNETCORE_ENVIRONMENT`). `appsettings.<Env>.json` yalnızca sır içermeyen ayar; sırlar ortam değişkeni veya VPS'teki `.env` (git dışı, `chmod 600`). Ortam sırları GitHub Environments'ta; Production ortamı yalnız `main` + manuel onay.
- Local sır: .NET `dotnet user-secrets`; Flutter `--dart-define-from-file=env/<env>.json` (`env/` git dışı). Repoda yalnız değersiz şablon: `.env.example`, `env/example.json`.
- gitignore'da ayrıca: `key.properties`, `*.jks`, `*.pfx`, provisioning profilleri. Android keystore repoya değil şifreli yedeğe; kaybı uygulamayı güncellenemez yapar. **Sızan sır ölü sırdır:** önce döndür, sonra `git filter-repo`.
- Test ve Demo'da gerçek müşteri verisi bulunmaz (KVKK): sentetik veya maskelenmiş veri. Her ortamın ayrı DB'si ve ayrı kullanıcısı; uygulama kullanıcısında DDL yetkisi yok, migration ayrı kullanıcıyla.
- **Bir kez derle, her yerde çalıştır:** imaj ortam bilgisi içermez; Test'te denenen etiket aynı haliyle Demo ve Prod'a gider, fark yalnız env değişkeni. Flutter ortamı `--dart-define` ile; üretim paketi test API'sine bağlanamaz (derleme zamanı kontrolü). Kodda `if (env == "Production")` yok.

## Docker
- Çok aşamalı Dockerfile (`sdk` → `aspnet` runtime); root olmayan kullanıcı; sabit taban imaj etiketi (`mcr.microsoft.com/dotnet/aspnet:10.0`, LTS); konteynerde `TZ=UTC`; `HEALTHCHECK`; imaj etiketi sürüm + commit (`api:1.4.0-a1b2c3d`), `latest` tek başına değil.
- `compose.yaml` yerel geliştirme için (api + <PostgreSQL 18 | veri tabanı> + opsiyonel yönetim aracı; PostgreSQL ICU ile kurulur: `POSTGRES_INITDB_ARGS=--locale-provider=icu --icu-locale=tr-TR`, `pg_trgm` eklentisi migration'da); `compose.<env>.yaml` ortam farkları. Veri `volumes` ile; `.dockerignore` zorunlu.
- İmaj içinde sır yok; migration imaj başlangıcında değil, `yayin` adımında ayrı komutla.

## VPS
- Erişim yalnızca SSH anahtarı; parola girişi ve root girişi kapalı; `ufw` ile 22/80/443; `fail2ban`.
- Ters vekil <Caddy | Nginx> ile TLS (Let's Encrypt); uygulama yalnızca iç ağda dinler. Ortamlar alt alan adlarında yan yana (`test.`, `demo.`, kök = Prod), her biri ayrı compose projesi; Demo basic-auth veya IP kısıtı arkasında.
- Yayın: `deploy/deploy.sh <ortam> <sürüm>` → imajı çek, `compose` ile değiştir, sağlık kontrolü, hata durumunda önceki etikete dön. Elle `docker run` yok. `main` merge → Test'e otomatik; Demo ve Prod yalnız onayla.
- Yedek: veri tabanı günlük dökümü (<`pg_dump` | ...>) + yükleme klasörü; yedekler VPS dışına; ayda bir geri yükleme provası. Loglar `docker logs` + <Seq | Loki>, correlation ID ile aranabilir; çökme raporları <Sentry | Crashlytics>. Uyarı <kanal>: disk/bellek, sağlık ucu düşmesi, hata oranı sıçraması.
```
