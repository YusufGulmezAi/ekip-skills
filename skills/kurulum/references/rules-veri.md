# `.claude/rules/veri.md` şablonu (≤ 60 satır; PostgreSQL kullanan projede)

```markdown
---
paths: ["**/*.cs", "**/*.sql", "**/Migrations/**", "**/compose*.y*ml"]
---
# Veri kuralları: sürüm, Türkçe metin, zaman, genel kimlik

**Mevcut projede:** bu kurallar sonradan geldiyse eski tablolar ve kod kendiliğinden uymaz. Dokunduğun tabloya/koda uygula; uymayan diğerlerini bitiş raporunda "kural borcu" olarak tek tek listele (sessizce kapsam daraltma yok). Toplu geçiş ayrı iş ve onayla. Bir ADR bilinçli olarak farklı karar verdiyse bu borç değildir; raporda ADR'ye atıfla anılır.

## Sürümler
- .NET 10 LTS (`net10.0`; destek 14.11.2028). SDK `global.json` ile sabit: `"version": "10.0.<yama>", "rollForward": "latestFeature", "allowPrerelease": false` (global.json yoksa CLI önizleme SDK'yı da seçebilir). EF Core 10, Npgsql.EntityFrameworkCore.PostgreSQL 10.x, PostgreSQL <18>. STS sürüm (11, 13) kullanılmaz; yeni LTS'e geçiş karar kaydıyla.
- **Önizleme yok:** preview/rc/beta/alpha/dev sürüm hiçbir yerde kullanılmaz — SDK, NuGet ve pub paketleri, Docker imaj etiketleri, Flutter kanalı (yalnız `stable`).

## Türkçe metin: arama, eşitlik, sıralama
- Sorun (PostgreSQL'de ölçüldü): hiçbir veri tabanı ayarı tek başına çözmez. ICU `tr-TR`'de `lower('ISPARTA') = 'ısparta'` olduğundan `ILIKE 'isparta'` Isparta/ISPARTA/isparta'nın yalnız 1'ini bulur; C/en yerel ayarında 3'ünü bulur ama `ILIKE 'izmir'` "İzmir"i bulamaz. Kullanıcı iki yönde de yazar ("ISPARTA", "izmir", "isik"); tek çözüm ı/i ve aksan katlayan normalleştirme. Kodda kültürsüz `ToLower()`/`ToUpper()` aynı hatayı uygulamada üretir.
- Başvuru kodu (testli, .NET 10, ICU'lu ve ICU'suz konteynerde aynı sonuç): `TextNormalizer`, `LocalDateRange`, `PublicIdGenerator` — `kurulum` projeye `src/<Proje>/Common/` altına kopyalar, testlerini `tests/.../Unit/Common/` altına.
- **Kodda kültür her zaman açık.** Kimlik, kod, anahtar: `ToLowerInvariant()` + `StringComparison.Ordinal`/`OrdinalIgnoreCase`. Kullanıcı metni yalnız `TextNormalizer` içinde `CultureInfo("tr-TR")` ile. `.editorconfig`: CA1304, CA1309, CA1311 = error.
- **Arama normalleştirilmiş sütunda.** Aranan her metin alanının yanında `<Alan>Search` sütunu; değeri `TextNormalizer.ForSearch()` üretir: tr küçük harf → `ç→c ğ→g ı→i ö→o ş→s ü→u`, aksan silme, boşluk sadeleştirme. `SaveChanges` önleyicisi doldurur; elle atanmaz.
- Sorgu: terim aynı fonksiyonla normalleşir; `EF.Functions.Like(x.TitleSearch, $"%{escaped}%", "\\")` (`%`, `_`, `\` kaçırılır). "isik", "IŞIK", "ışık" aynı kaydı bulur.
- İndeks: `CREATE EXTENSION pg_trgm`; `<Alan>Search` üzerinde GIN trigram (`HasMethod("gin").HasOperators("gin_trgm_ops")`).
- Yapılmaz: aramada `ILIKE`/`lower()`; büyük/küçük harf duyarsız (nondeterministic) ICU collation ile arama — PG 18'de `ILIKE` hata verir, `LIKE '%x%'` indeks kullanamaz ve ~10 kat yavaştır.
- Sıralama Türkçe alfabeyle: sıralanan sütunda `UseCollation("tr-TR-x-icu")` ya da veri tabanı ICU ile kurulur (`POSTGRES_INITDB_ARGS: --locale-provider=icu --icu-locale=tr-TR`). Benzersizlik `<Alan>Search` ya da invariant sütunda.
- Test: Testcontainers PostgreSQL (InMemory/SQLite collation ve LIKE'ı taklit etmez): "Işık/IŞIK/ışık/isik", "İzmir/izmir/IZMIR", "Çağrı/cagri", "%" ve "_" içeren terim.

## Zaman ve saat dilimi
- An (oluşturma, çözme, onay): `timestamptz` + `DateTimeOffset` UTC. Takvim günü (son tarih, teslim günü): `date` + `DateOnly`. Anlar için `timestamp without time zone` yok; `Npgsql.EnableLegacyTimestampBehavior` açılmaz.
- Kiracının saat dilimi verisi: `TimeZoneId` (IANA, varsayılan `Europe/Istanbul`). Sunucu ve konteyner `TZ=UTC`; makine saatine ve sabit `+03:00` ofsetine güvenilmez.
- **Tarih filtresi yarı açık UTC aralığıdır.** İstemci yerel günleri `DateOnly` (`yyyy-MM-dd`) gönderir; sunucu `LocalDateRange.ToUtc(from, to, tz)` ile `[from 00:00 yerel, (to+1) 00:00 yerel)` aralığını UTC'ye çevirir; sorgu `>= start AND < end`. Yasak: `<= 23:59:59`, `.Date` karşılaştırması, UTC günüyle filtre (ölçüldü: yerel 29.10 için doğru aralık 2 kayıt, `created_at::date` 1 kayıt verdi).
- Gün/ay gruplama: `date_trunc('day', created_at AT TIME ZONE @tz)` (parametreli); UTC güne göre gruplama yasak.
- Test: `FakeTimeProvider` ile sınır anları — yerel 00:30 (UTC'de önceki gün 21:30), yerel 23:59, ay ve yıl sonu; sonuç tam kayıt sayısıyla doğrulanır.
- İstemciye an UTC (ISO 8601) gider, gösterim yerelde; istemci filtrede saat değil `DateOnly` gönderir.

## Genel kimlik (PublicId)
- URL'de, rotada, DTO'da ya da kullanıcıya referans olarak gösterilen her varlıkta `Guid Id` (birincil anahtar, ilişkiler, iç kullanım) + `string PublicId`: tam 10 küçük ASCII harf `[a-z]{10}` (Türkçe harf yok), tablo içinde benzersiz. Dışarı hiç çıkmayan tablolarda (bağlantı, geçmiş satırı) gerekmez.
- URL, rota, DTO ve paylaşılan bağlantı yalnız `PublicId` kullanır; `Guid` dışarı verilmez. DTO'da alan adı `publicId`.
- Üretim `PublicIdGenerator.New()`: `RandomNumberGenerator.GetInt32(26)` (kriptografik); `Random`, sayaç ya da Guid'den türetme yok — tahmin ve numaralandırma engellenir. 26^10 ≈ 1,4×10^14 değer.
- Veri tabanı: `text COLLATE "C"` (`char(10)` değil: boşlukla doldurur; yerel ayara bağlı collation karşılaştırmayı ve indeksi ortamdan ortama değiştirir), benzersiz indeks, `CHECK (public_id ~ '^[a-z]{10}$')`. Atama `SaveChanges` önleyicisinde; o indekste benzersizlik ihlali (`23505`) olursa yeni değerle en fazla 3 deneme. Oluşturulduktan sonra değişmez.
- Rota: `/{publicId:regex(^[a-z]{{10}}$)}`; biçimsiz değer 404. Kiracı filtresi `PublicId` aramasında da geçerli: başka sitenin kimliği 404.
- Çevrimdışı istemci kayıt kimliğini (UUID v7) üretir; `PublicId` sunucuda atanır ve senkron yanıtında döner.
```
