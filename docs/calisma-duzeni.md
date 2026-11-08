# Çalışma düzeni: yerel makine ve bulut oturumu

Karar: 6 Kasım 2026 (Yusuf). Bu belgenin kopyası claude.ai'deki "Ekip Skill im" projesinde de durur; yerel oturumlar bu depodaki kopyayı okur.

## İş bölümü

| Yer | Ne yapılır |
|---|---|
| **Yerel makine** (VS Code + Claude Code, `X:\src`) | Günlük ana geliştirme: projeler ve ekip-skills'in kendisi. Docker, tarayıcıda ekran onayı, emülatör, tam test paketi; eklentiyi gerçek projede anında deneme. |
| **Bulut oturumu** (claude.ai) | Başında durulması gerekmeyen uzun işler: uzun eval turları, test yazma, yeniden düzenleme, migration hazırlığı, belge, analiz. Telefondan ya da başka cihazdan devam. |

## Akış
1. İş başlamadan önce depo en güncel haliyle alınır; aynı dalda iki yer aynı anda çalışmaz.
2. Bulut işi `bulut/<konu>` dalında yapılır; `main`'e doğrudan yazılmaz.
3. Testler yeşilse dal push edilir; rapor dal adını, değişen dosyaları, koşan testleri ve yerelde bakılacakları yazar.
4. Yerelde dal çekilir, bakılır; onaylanırsa `main`'e birleştirilir:

```powershell
cd X:\src\<Proje>
git fetch origin
git switch bulut/<konu>
git switch main
git merge --ff-only bulut/<konu>
git push
git push origin --delete bulut/<konu>
```

## Devir kuralı
claude.ai projesindeki belgeleri yerel oturum göremez. Yerel oturumun okuması gereken plan, iş listesi ya da karar ilgili deponun `docs/` klasörüne yazılır ya da oturuma yapıştırılacak metin olarak verilir.

## ekip-skills'i yerelde geliştirme
```powershell
cd X:\src\ekip-skills
claude plugin disable ekip-skills@ekip-skills --scope local   # bu depoda kurulu kopya kapalı
claude --plugin-dir X:\src\ekip-skills                        # düzenlenen kopyayla deneme (VS Code terminalinde)
```
- Açık iş listesi ve projelerden gelen `[ekip-skills]` dersleri: [yapilacaklar.md](yapilacaklar.md).
- Eval'ler bash betikleriyle kurulur: WSL (Ubuntu) içinde koşturulur.
- Sürüm: `plugin.json` sürümü artar → `main` → `gh release create vX.Y.Z` → `claude plugin marketplace update ekip-skills` + `claude plugin update ekip-skills@ekip-skills` → VS Code'u yeniden başlat ya da `/reload-plugins`.

## Bulut ortamının sınırları (6 Kasım 2026'da ölçüldü)
- Var: .NET SDK kurulabilir, NuGet / pub.dev / npm, PostgreSQL 16, Playwright, GitHub'a dal push.
- Yok: Docker motoru, çalışan uygulamayı tarayıcıda görme, emülatör; etiket push edilemez.
- 2 çekirdek, 7 GB RAM. Oturum kullanılmazsa kapanır; push edilmeyen iş kaybolur.
- Yerelde kurulu eklentiler bulutta yüklenmez; bulutta kurallar depodan okunur.
