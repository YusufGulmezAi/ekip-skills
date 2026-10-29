# PR #37 — Taşeron atama

Birleşti: 2026-10-27

## Ne oldu
- Müteahhit için `POST /kusurlar/{id}/ata` uç noktası eklendi. Taşeron listesini çekerken `IgnoreQueryFilters()` kullanıldı; incelemede başka firmanın taşeronlarının da listelendiği bulundu, düzeltildi.
- İkinci incelemede aynı hata `GET /taseronlar` uç noktasında tekrar bulundu, yine `IgnoreQueryFilters()`.
- Flutter atama ekranında `await` sonrası `context` kullanıldı; `use_build_context_synchronously` uyarısı `// ignore` ile susturulmuştu, incelemede iki kez geri gönderildi.
- Taşeron seçim listesi için tasarım notu yoktu; ekran iki kez yeniden yapıldı.
