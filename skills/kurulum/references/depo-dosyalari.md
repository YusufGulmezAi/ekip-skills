# Depo dosyaları: `.gitattributes` ve `.editorconfig` adlandırması

## `.gitattributes` — BOM'suz UTF-8, ilk satır açıklama
BOM'lu dosyada git ilk satırı BOM ile birlikte okur ve o satırdaki kuralı tanımaz. fintech-core'da ilk kural `* text=auto eol=lf` bu yüzden etkisiz kaldı: 805 dosya CRLF, üretilmiş dosyalar sürekli "M", `dotnet format`'ta 87 bin hata. Bu yüzden:
- Dosya BOM'suz yazılır (Write aracı; PowerShell 5.1'de `Set-Content`/`Out-File -Encoding utf8` BOM ekler, `[IO.File]::WriteAllText($yol, $metin, [Text.UTF8Encoding]::new($false))` eklemez).
- İlk satır açıklamadır: BOM yine de girerse yalnız açıklama bozulur, kural değil. Doktor betiği BOM'u denetler.

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
