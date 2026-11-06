# .NET kontrol listesi

**Kritik adayları**
- EF Core migration'da kolon silme/yeniden adlandırma: rename bazen drop+add üretir, veri kaybı. Migration'ın `Up()` içeriğini oku.
- `FromSqlRaw` / `ExecuteSqlRaw` içinde string birleştirme veya interpolasyon → `FromSql`/parametre.
- Çok kiracılı (multi-tenant) kodda tenant filtresi: global query filter yoksa veya `IgnoreQueryFilters()` kullanılmışsa gerekçesi var mı.
- `[Authorize]` / `.RequireAuthorization()` eksik uç nokta.
- `appsettings.json` içinde düz metin sır.

**Önemli adayları**
- Eşleme kütüphanesi (`AutoMapper`, `Mapster`, `Mapperly`, `MapperConfiguration`) kullanımı → ekip kuralı: `static <Entity>Mapper` uzantı metotları, testli. Uç noktada `new XxxDto(...)`/`new Entity {...}` (rapor ve sorgu çıktıları dahil) → eşleyiciye.
- Kural kapsamı sessizce daraltılmış: proje kuralı (ör. `veri.md` PublicId, arama sütunu) yalnız bir kısma uygulanmış ve rapor "kural borcu" listesi vermiyor.
- Public tür/üyede Türkçe XML doc yok ya da İngilizce → API başvurusu ve eğitim dokümanı eksik kalır.
- Kullanıcıya dönen düz string mesaj (yerelleştirme anahtarı yerine); mesajda `$"..."` ile gömülü parametre; yeni anahtarın `docs/mesajlar.md`'ye işlenmemesi.
- İngilizce olmayan tür, üye, dosya veya tablo adı (alan terimi sözlükteki İngilizce karşılığıyla olmalı).
- `HttpClient` istek başına `new`/`using` ile oluşturuluyor (soket tükenmesi) → `IHttpClientFactory`, typed client veya `PooledConnectionLifetime` ayarlı tek örnek. Diğer `IDisposable`'lar (`DbConnection`, `Stream`) `using`/`await using` ile.
- `async` kodda `.Result`/`.Wait()` (ASP.NET Core'da thread-pool tükenmesi); `async void` (olay yöneticisi dışında); uzun/ağ çağrısına `CancellationToken` iletilmemesi.
- EF Core: döngü içinde sorgu (N+1); salt okuma sorgusunda `AsNoTracking` eksikliği; gereksiz `ToList()`; döngüde `SaveChanges`.
- DI yaşam süresi uyumsuzluğu (singleton içinde scoped); `new` ile elle kurulan bağımlılık.
- Nullable uyarılarının `!` ile susturulması.
- `DateTime.Now` (saat dilimi) → `TimeProvider` / UTC.
- Türkçe metin: kültürsüz `ToLower()`/`ToUpper()`/`string.Compare`; aramada `ILIKE`, `lower()` ya da nondeterministic collation; normalleştirilmiş `<Alan>Search` sütunu yerine ham sütunda `Contains`/`Like`; ı/i ya da ç/c'yi birbirine katlayan normalleştirme ("isparta" ISPARTA'yı bulmamalı, "cagri" Çağrı'yı bulmamalı; kural: `veri.md`).
- Tarih filtresi: `<= 23:59:59`, `.Date ==` karşılaştırması, UTC günüyle filtre ya da gruplama, sabit `+3` ofset; yarı açık aralık `LocalDateRange.ToUtc` ile olmalı. Anda `timestamp without time zone`.
- Dışarı açılan `Guid` (rota, DTO, bağlantı) → `PublicId`; `PublicId` üretiminde `Random`/sayaç/Guid türetmesi; benzersiz indeks ya da `CHECK` eksikliği; kolon `char(10)` ya da collation'sız (`text COLLATE "C"` olmalı).
- Ebeveynde aşağı doğru navigation koleksiyonu (`ICollection<Child>`) gerekçesiz; modüller arası erişim sözleşme katmanı dışından; kırmızı çizgiyi (kiracı filtresi, modül sınırı) zorlayan mimari test yok ya da izin listesine gerekçesiz satır eklenmiş.
- Hedef çerçeve `net10.0` (LTS) değil ya da `global.json` yok / `allowPrerelease: false` içermiyor.
- Önizleme sürüm: `PackageReference` sürümünde `-preview`, `-rc`, `-beta`, `-alpha`; Dockerfile/compose'da `rc`/`beta`/`preview` etiketli imaj.
- Günlükte interpolasyon (`$"..."`) yerine mesaj şablonu (CA2254).
- Zafiyetli paket: `dotnet list package --vulnerable` / NuGetAudit uyarıları.
