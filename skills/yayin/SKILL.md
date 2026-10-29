---
name: yayin
description: Bir sürümü yayına hazırlar ve her adımı kanıtla doğrular; sürüm numarası, değişiklik günlüğü, migration sırası ve yedek, .NET Docker imajı, Flutter Android/iOS paketleri, mağaza notları, duman testi, geri dönüş planı. USE FOR — "yayınla", "sürüm çıkar", "release", "deploy", "canlıya al", "mağazaya gönder", "TestFlight", "Play Console", "yayın kontrol listesi". DO NOT USE FOR — günlük commit ve PR (`uygula`, `incele`), yalnızca değişiklik günlüğü yazmak (`belgele`).
argument-hint: "[sürüm, örn. 1.4.0 | backend | mobil]"
disable-model-invocation: false
---

# Yayın

Amaç: yayının tekrarlanabilir, geri alınabilir ve kanıtlı olması. Yayın hatası kullanıcıya doğrudan ulaşır; mağaza incelemesi ya da migration geri alınması günler sürebilir.

**Kapı:** her adımı hazırlar, gösterir ve onay ister. Canlı ortama dokunan komutu (migration uygulama, imaj gönderme, mağazaya yükleme) kullanıcı onayı olmadan çalıştırma.

## Kontrol listesi
Her maddede çalıştırılan komutu ve çıktısını yaz; çalıştırılamayan madde "yapılmadı" olarak kalır ve çalıştırılacak komut raporda **eksiksiz** yazılır (bayraklar ve yollarla). Gerekçe: "yapılmadı" diyen ama komutu göstermeyen rapor, kullanıcıya neyi çalıştıracağını söylemez; en çok atlanan bayraklar (`--obfuscate`, `--split-debug-info`, `--idempotent`) tam burada kaybolur.

1. **Hazır mı?** Ana dal temiz ve güncel; CI yeşil (üç test katmanı + zafiyet taraması); açık Kritik `incele` veya `guvenlik-testi` bulgusu yok; plandaki görevler kapalı. Sözleşme: `oasdiff breaking <son-tag> <şimdi>` — kırıcı fark varsa sürüm MAJOR artmalı ve `/api/vN` kuralı uygulanmalı.
2. **Sürüm.** `bash "${CLAUDE_PLUGIN_ROOT}/skills/yayin/scripts/surum-kontrol.sh" <sürüm>` çalıştır: pubspec, .NET `Version`, CHANGELOG başlığı ve git etiketi tutarlılığını raporlar (betik yoksa aynı dört yeri elle kontrol et). SemVer (MAJOR.MINOR.PATCH); **tek kaynak git tag'idir** (`v1.4.0`), pubspec ve `Directory.Build.props` ona uyar — iki yerde elle sürüm tutma, kayar. Flutter `pubspec.yaml`: `version: 1.4.0+<build>`, build numarası her mağaza yüklemesinde artar, asla geri gitmez. Mağaza öncesi deneme sürümü `1.5.0-rc.1` (TestFlight / internal track); rc Prod'a çıkarken yalnız tag değişir, imaj aynı kalır.
3. **Değişiklik günlüğü.** Taslağı Conventional Commits'ten üret (`git-cliff --latest`; yoksa `git log <son-tag>..HEAD --oneline`), `belgele` ile `CHANGELOG.md`'ye işle ve kullanıcıya dönük Türkçe sürüm notuna çevir.
4. **Backend.**
   - Migration betiği: `dotnet ef migrations script <son-yayın> --idempotent -o artifacts/migrate-<sürüm>.sql`; betiği oku, veri kaybı yaratan işlem (DROP, kolon yeniden adlandırma) varsa dur ve göster.
   - Veri tabanı yedeği alındığını doğrula.
   - Sıra: yedek → migration → yeni sürüm. Uygulama yeni şemayla eski sürümle uyumlu değilse bunu açıkça yaz.
   - Docker imajı: sürüm + commit etiketiyle (`api:1.4.0-a1b2c3d`), **bir kez derlenir**; Test'te denenen etiket yeniden derlenmeden Demo'ya, Demo'da onaylanan Prod'a gider. VPS'e `deploy/deploy.sh <ortam> <sürüm>` ile (imaj çek → compose değiştir → sağlık kontrolü → hata durumunda önceki etikete dön). Elle `docker run` yok; kurallar `.claude/rules/altyapi.md`.
5. **Mobil.**
   - Android: `flutter build appbundle --release --obfuscate --split-debug-info=build/symbols/<sürüm>`
   - iOS (macOS gerekir): `flutter build ipa --release --obfuscate --split-debug-info=build/symbols/<sürüm>`
   - Sembol klasörünü sürümle birlikte sakla; olmadan çökme raporu okunamaz.
   - API uyumu: yeni uygulama eski API ile, eski uygulama yeni API ile çalışıyor mu? Mağaza güncellemesi herkese aynı anda ulaşmaz. Kırıcı değişiklik API sürümüyle (`/api/v2` yan yana, `v1` bir süre yaşar); asgari desteklenen uygulama sürümü uç noktası güncellenecekse yaz.
6. **Mağaza.** Sürüm notu (Türkçe), gerekiyorsa ekran görüntüleri, izin açıklamaları (kamera, konum, depolama), gizlilik bildirimi değişti mi.
7. **Duman testi.** Canlıda en kritik akış (profildeki akış; ör. giriş → kayıt oluştur → gönder) elle veya otomatik; sonucu yaz.
8. **Geri dönüş planı.** Önceki imaj etiketi, migration'ın geri alınabilirliği, mobilde zorunlu güncelleme gerekip gerekmediği.
9. **Kayıt.** Sürüm etiketi (`git tag v1.4.0`), yayın notu, sembollerin yeri. Ardından `retro`.
