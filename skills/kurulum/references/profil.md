# Proje profili şablonu (≤ 40 satır, CLAUDE.md içine)

```markdown
## Proje profili

### Ürün ve roller
- <Ne yapar, bir cümle>
- Roller: <rol: cihaz, ortam> · <rol: cihaz, ortam>

### Yığın
- Backend: .NET 10 (LTS), <minimal API | controller>, EF Core 10 + <PostgreSQL 18 | veri tabanı>; varsayılan kiracı saat dilimi <Europe/Istanbul>
- Mobil: Flutter <sürüm>, <Riverpod | Bloc | Provider>, <go_router | ...>
- Sözleşme: <api/openapi.yaml>; tasarım sistemi: <ad>; bileşen kütüphanesi: <packages/<urun>_ui | lib/shared/widgets | yok>
- Çevrimdışı: <modüller | yok> · çakışma: <ekle-yalnız | rowversion+409> · ön paket: <birim>

### Komutlar
- Derleme: <komut> · Test: <komut> · Kod üretimi: <komut | yok> · Yerel ortam: <komut> · Seed: <komut | yok>

### Dokümanlar
- Harita `docs/README.md` · Sözlük `docs/sozluk.md` · Öğrenimler `docs/agent/ogrenimler.md`
- Kararlar `docs/kararlar/` · Kullanıcı `docs/kullanici/<rol>/` · Planlar `docs/planlar/`
- Kurallar: `.claude/rules/dotnet.md`, `veri.md`, `flutter.md`, `altyapi.md`

### İş takibi ve kaynak kontrol
- Issue: <sistem> · Etiketler: <...> · Dal: `<tür>/<no>-<ad>` · Commit: Conventional Commits (İngilizce başlık)
- Kontrol noktası: tüm testler yeşilse iş dalına otomatik commit + push (`main`'e asla doğrudan). `main` korumalı: PR + 1 onay + CI. Ortamlar: <Development | Test | Demo | Production>. Ayrıntı: `.claude/rules/altyapi.md`

### Çalışma tercihleri (eklenti varsayılanlarını bu proje için değiştirir)
- Adlandırma: <İngilizce + sözlük (varsayılan) | Türkçe alan tipleri, İngilizce altyapı>
- Ekran onayı: <önce mockup (varsayılan) | mockup istendiğinde; onaylı desen + spesifikasyonla kod, çalışan ekranda yazılı onay>; bileşen onayı: <mockup | canlı katalog sayfası>
- Çalışma düzeni: <tek oturum (varsayılan) | mimar + geliştirici ajan: ana oturum kod yazmaz>
- Git yetkisi: <temkinli (varsayılan): zorla push ve PR onaylı | geniş: push, PR ve `--force-with-lease` onaysız>; veri silen işlem her durumda onaylı
- Durum dosyası: <docs/agent/durum.md | docs/DURUM.md> · Geliştirici kabuğu: <PowerShell | bash> (yerel deneme bloğu bu kabukta verilir)

### Onay gerektirenler
Paket ekleme, migration üretme/uygulama, sözleşme değişikliği, yayın, veri silme.
```
