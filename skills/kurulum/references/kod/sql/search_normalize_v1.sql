-- Türkçe arama biçimi: TextNormalizer.ForSearch (C#) ile birebir aynı adımlar, aynı sıra. PostgreSQL 17+ (pg_c_utf8).
-- 1) I→ı, İ→i  2) lower (pg_c_utf8: Unicode basit küçültme, ICU/libc'den bağımsız)  3) ı+U+0307→i
-- 4) â î û → a i u; U+0302 ve U+0307 silinir  5) boşluk dizileri tek boşluk, baş/son boşluk silinir.
-- Kullanım: <alan>_search text GENERATED ALWAYS AS (search_normalize_v1(<alan>)) STORED
-- Değişmez: davranış değişirse CREATE OR REPLACE yapılmaz (üretilmiş sütunlar yeniden hesaplanmaz, bayat kalır);
-- yeni ad (search_normalize_v2) + ALTER TABLE ... ALTER COLUMN <alan>_search SET EXPRESSION AS (search_normalize_v2(<alan>)).
CREATE FUNCTION search_normalize_v1(input text) RETURNS text
LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
RETURN btrim(
  regexp_replace(
    translate(
      replace(lower(translate(input, 'Iİ', 'ıi') COLLATE pg_c_utf8), 'ı' || U&'\0307', 'i'),
      'âîû' || U&'\0302\0307', 'aiu'),
    '\s+', ' ', 'g'),
  ' ');
