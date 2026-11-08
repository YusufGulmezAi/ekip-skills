# Depo dosyaları: `.gitattributes` ve `.editorconfig` adlandırması

## `.gitattributes` — BOM'suz UTF-8, ilk satır açıklama
fintech-core'da ilk kural `* text=auto eol=lf` etkisiz kaldı: 805 dosya CRLF, üretilmiş dosyalar sürekli "M", `dotnet format`'ta 87 bin hata. Ölçüm (git 2.56, 08.11.2026): **UTF-16** dosyada (PowerShell 5.1'de `>`, `Out-File` varsayılanı) git hiçbir kuralı okumaz; UTF-8 BOM'u ise atlar, kural çalışır (eski git sürümleri ilk satırı tanımayabilir). Bu yüzden:
- Dosya BOM'suz UTF-8 yazılır: Write aracı ya da `[IO.File]::WriteAllText($yol, $metin, [Text.UTF8Encoding]::new($false))`. PowerShell 5.1'de `>`/`Out-File` UTF-16, `Set-Content -Encoding utf8` UTF-8 BOM'lu yazar.
- **UTF-16 ya da BOM'lu dosya düzenlenmez, silinip yeniden yazılır:** Edit/Write aracı mevcut dosyanın kodlamasını korur (ölçüldü: düzenlenen UTF-16 dosya BOM'u kaybedip yine UTF-16 kaldı). Önce `rm .gitattributes`, sonra Write ile yeni dosya.
- İlk satır açıklamadır: BOM girerse yalnız açıklama bozulur, kural değil.
- **Kanıt (atlanmaz):** `head -c4 .gitattributes | od -An -tx1` → `23 20 …` (`# `; `00` ya da `ff fe`/`ef bb bf` yok) ve `git check-attr text eol -- <bir .cs dosyası>` → `text: auto`, `eol: lf`. Doktor betiği UTF-16'yı ve BOM'u denetler.

```gitattributes
# Satır sonları: depoda LF. Bu dosya BOM'suz UTF-8 kaydedilir (BOM ilk satırdaki kuralı etkisiz bırakır).
* text=auto eol=lf
*.cmd text eol=crlf
*.bat text eol=crlf
*.png binary
*.jpg binary
*.pdf binary
```
Mevcut depoda kural ilk kez geliyorsa ya da değişiyorsa: `git add --renormalize .` ayrı commit'te (`chore: normalize line endings`), ardından `git status` temiz olmalı; temiz değilse nedenini raporla.

## `.editorconfig` — adlandırma kuralı projenin alışkanlığından
IDE1006 (adlandırma) açık kalır. `private static readonly` alan ve yerel `const` için kural yazılmazsa bu semboller genel kurala düşer ve projede yüzlerce IDE1006 ihlali çıkar (fintech-core). Kuralı uydurmadan önce projede say:
- `git grep -hoE 'private static readonly [^=;(]+ [_a-zA-Z][A-Za-z0-9]*' -- '*.cs'` → son kelime `_camelCase`, `s_camelCase` ya da `PascalCase` mi?
- `git grep -hoE '^\s+const [A-Za-z<>?]+ [A-Za-z][A-Za-z0-9]*' -- '*.cs'` → `PascalCase` mi `camelCase` mi?
Çoğunluk kurala yazılır; iki biçim yakınsa sor. Yeni projede varsayılan: alan `PascalCase`, yerel `const` `PascalCase`.

```ini
[*.cs]
dotnet_diagnostic.IDE1006.severity = warning

dotnet_naming_symbols.private_static_readonly.applicable_kinds = field
dotnet_naming_symbols.private_static_readonly.applicable_accessibilities = private
dotnet_naming_symbols.private_static_readonly.required_modifiers = static, readonly
dotnet_naming_rule.private_static_readonly.symbols = private_static_readonly
dotnet_naming_rule.private_static_readonly.style = <pascal_case | underscore_camel_case | s_camel_case>
dotnet_naming_rule.private_static_readonly.severity = warning

dotnet_naming_symbols.local_const.applicable_kinds = local
dotnet_naming_symbols.local_const.required_modifiers = const
dotnet_naming_rule.local_const.symbols = local_const
dotnet_naming_rule.local_const.style = <pascal_case | camel_case>
dotnet_naming_rule.local_const.severity = warning

dotnet_naming_style.pascal_case.capitalization = pascal_case
dotnet_naming_style.camel_case.capitalization = camel_case
dotnet_naming_style.underscore_camel_case.capitalization = camel_case
dotnet_naming_style.underscore_camel_case.required_prefix = _
dotnet_naming_style.s_camel_case.capitalization = camel_case
dotnet_naming_style.s_camel_case.required_prefix = s_
```
Kullanılmayan stil satırları silinir. Yazdıktan sonra `dotnet build` uyarı sayısı kural öncesiyle karşılaştırılıp raporlanır.
