## Proje profili

### Ürün
- Ne yapar: Yeni inşaat dairelerinde mahal bazlı kusur tespiti ve çok taraflı onay akışı.
- Kullanıcı rolleri: Emlak ofisi (saha: telefon/tablet), Müşavir (web), Müteahhit (web), Taşeron (telefon).

### Yığın
- Backend: .NET 9, ASP.NET Core minimal API, EF Core + PostgreSQL
- Mobil: Flutter 3.x, state management: Riverpod, routing: go_router
- API sözleşmesi: `api/openapi.yaml`

### Komutlar
- Derleme: `dotnet build Tespit.sln`
- Test: `dotnet test` (xUnit); Flutter: `cd mobile && flutter test`

### Düzen
- Uç noktalar `src/Tespit.Api/Endpoints/` altında, her kaynak için bir `Map*Endpoints` uzantısı.
- Kiracı filtresi `TespitDbContext` içinde global query filter olarak.

### Dokümanlar
- Harita: `docs/README.md` · Sözlük: `docs/sozluk.md` · Öğrenimler: `docs/agent/ogrenimler.md`

### Onay gerektirenler
Paket ekleme, migration uygulama, yayın.
