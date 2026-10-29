#!/usr/bin/env bash
# Sürüm tutarlılığı: pubspec.yaml, Directory.Build.props/csproj Version, CHANGELOG başlığı, git etiketi.
# Kullanım: surum-kontrol.sh <hedef-sürüm>   örn. 1.4.0
# Değiştirmez; yalnızca raporlar. Tutarsızlık varsa çıkış kodu 1.
set -u
hedef="${1:?hedef sürüm gerekli, örn. 1.4.0}"
hata=0
pub=$(find . -maxdepth 3 -name pubspec.yaml -not -path '*/.dart_tool/*' 2>/dev/null | head -1)
if [ -n "$pub" ]; then
  v=$(grep -m1 -E '^version:' "$pub" | sed -E 's/^version:\s*//')
  surum="${v%%+*}"; build="${v#*+}"
  if [ "$surum" = "$hedef" ]; then echo "OK    pubspec  $v"; else echo "FARK  pubspec  $v (hedef $hedef)"; hata=1; fi
  [ "$build" = "$v" ] && { echo "EKSIK pubspec  build numarası yok (version: $hedef+N bekleniyor)"; hata=1; }
fi
props=$(grep -rl --include='Directory.Build.props' --include='*.csproj' -E '<Version>' . 2>/dev/null | head -1)
if [ -n "$props" ]; then
  v=$(grep -m1 -oE '<Version>[^<]+' "$props" | sed 's/<Version>//')
  if [ "$v" = "$hedef" ]; then echo "OK    dotnet   $v ($props)"; else echo "FARK  dotnet   $v ($props, hedef $hedef)"; hata=1; fi
else
  echo "BILGI dotnet   <Version> tanımı yok (Directory.Build.props önerilir)"
fi
if [ -f CHANGELOG.md ]; then
  if grep -qE "^## \[$hedef\]" CHANGELOG.md; then echo "OK    changelog [$hedef] başlığı var";
  elif grep -qiE '^## \[(Yayınlanmadı|Unreleased)\]' CHANGELOG.md; then echo "EKSIK changelog [$hedef] başlığı yok; Yayınlanmadı bölümü sürüme çevrilmeli"; hata=1;
  else echo "EKSIK changelog [$hedef] yok"; hata=1; fi
else
  echo "EKSIK changelog CHANGELOG.md yok"; hata=1
fi
if git rev-parse -q --verify "refs/tags/v$hedef" >/dev/null 2>&1; then echo "UYARI git      v$hedef etiketi zaten var"; hata=1; else echo "OK    git      v$hedef etiketi henüz yok"; fi
exit $hata
