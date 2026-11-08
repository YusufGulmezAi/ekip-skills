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
- **Kural (dil kuralı):** `ı↔I` ve `i↔İ` ayrı harf çiftleridir; `ç ş ğ ö ü` ayrı harftir (c s g o u ile eşleşmez); şapka sadeleşir (`â→a`, `î→i`, `û→u`). "isparta" → isparta, İsparta, İSPARTA (ISPARTA ve Isparta değil); "ısparta" → ısparta, Isparta, ISPARTA; "izmir" → İzmir (IZMIR değil); "kazım" → Kâzım; "cagri" Çağrı'yı bulmaz.
- Ölçüldü (PostgreSQL ICU): `tr-TR-x-icu` kolon + `ILIKE` büyük/küçük harfte kurala uyar ama şapkayı sadeleştirmez ("kazım" Kâzım'ı bulmaz) ve `%x%` için indeks kullanmaz; varsayılan (C/en) collation'da `ILIKE` kurala uymaz ("izmir" İzmir'i bulmaz, "isparta" ISPARTA'yı bulur). Kodda kültürsüz `ToLower()`/`ToUpper()` aynı hatayı uygulamada üretir.
- Başvuru kodu (testli, .NET 10, ICU'lu ve ICU'suz konteynerde aynı sonuç): `TextNormalizer`, `LocalDateRange`, `PublicIdGenerator` — `kurulum` projeye `src/<Proje>/Common/` altına kopyalar, testlerini `tests/.../Unit/Common/` altına. Arama için ayrıca `sql/search_normalize_v1.sql` (migration'a), `search-vectors.json` + `SearchVectorTests` (birim) ve `SearchEquivalenceTests` (entegrasyon, Testcontainers PostgreSQL 17+).
- **Kodda kültür her zaman açık.** Kimlik, kod, anahtar: `ToLowerInvariant()` + `StringComparison.Ordinal`/`OrdinalIgnoreCase`. Kullanıcı metninin aranacak biçimi yalnız `TextNormalizer` ile (Türkçe kural açık tabloda, kültürden bağımsız). `.editorconfig`: CA1304, CA1309, CA1311 = error.
- **Arama normalleştirilmiş sütunda, sütunu veri tabanı üretir (PG 17+).** Aranan her metin alanının yanında `<Alan>Search`: `<alan>_search text GENERATED ALWAYS AS (search_normalize_v1(<alan>)) STORED` (EF: `.HasComputedColumnSql("search_normalize_v1(<alan>)", stored: true)`, özellik salt okunur). Değer: Türkçe küçük harf (`I→ı`, `İ→i`), şapka ve ayrışık nokta sadeleşir, boşluk sadeleşir; Türkçe harfler korunur. Gerekçe: `SaveChanges` önleyicisi `HasData` tohumlarını, migration INSERT'lerini ve `ExecuteUpdate`'i atlar, sütun boş/bayat kalır; geri dolumda migration C# çalıştıramaz. PG 16'da önleyici + bayatlık testi, yükseltme planlanır.
- Terim ve bellek içi arama `TextNormalizer.ForSearch()` ile. **Eşdeğerlik testi zorunlu:** ortak `search-vectors.json` (C#, SQL ve istemci JS/Dart aynı dosyayı okur) + tüm kod noktalarının taraması (`SearchEquivalenceTests`). SQL fonksiyonu `IMMUTABLE`, `pg_c_utf8` ile ICU/libc'den bağımsız.
- **Fonksiyon değişmez:** `CREATE OR REPLACE` yok (üretilmiş sütun yeniden hesaplanmaz, bayat kalır); yeni ad (`search_normalize_v2`) + `ALTER TABLE … ALTER COLUMN <alan>_search SET EXPRESSION AS (search_normalize_v2(<alan>))`. Bayatlık testi: `count(*) WHERE <alan>_search IS DISTINCT FROM search_normalize_vN(<alan>)` = 0. Tuzak: üretilmiş sütunlu tabloya `INSERT … SELECT *` kopyası kırılır; sütunlar adıyla yazılır.
- Sorgu: terim aynı fonksiyonla normalleşir; `EF.Functions.Like(x.TitleSearch, $"%{escaped}%", "\\")` (`%`, `_`, `\` kaçırılır).
- İndeks: `CREATE EXTENSION pg_trgm`; `<Alan>Search` üzerinde GIN trigram (`HasMethod("gin").HasOperators("gin_trgm_ops")`); `LIKE '%ısparta%'` bu indeksi kullanır (ölçüldü).
- Yapılmaz: aramada ham sütunda `ILIKE`/`lower()`; büyük/küçük harf duyarsız (nondeterministic) ICU collation ile arama (PG 18'de `ILIKE` hata verir, `LIKE '%x%'` indeks kullanamaz). Mevcut projede `tr-TR-x-icu` + `ILIKE` varsa harf kuralı tutar; şapka ve indeks eksiği kural borcu olarak raporlanır.
- Sıralama Türkçe alfabeyle: sıralanan sütunda `UseCollation("tr-TR-x-icu")` ya da veri tabanı ICU ile kurulur (`POSTGRES_INITDB_ARGS: --locale-provider=icu --icu-locale=tr-TR`). Büyük/küçük harf duyarsız benzersizlik arama sütununda (`<alan>_search` üzerinde benzersiz indeks); kimlik ve kodda invariant sütunda.
- Test: Testcontainers PostgreSQL (InMemory/SQLite collation ve LIKE'ı taklit etmez); kayıtlar ISPARTA, Isparta, isparta, İSPARTA, İzmir, IZMIR, Çağrı, Kâzım; terimler "isparta", "ısparta", "izmir", "IZMIR", "kazım", "cagri"; beklenenler yukarıdaki kural; ayrıca "%" ve "_" içeren terim.

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
