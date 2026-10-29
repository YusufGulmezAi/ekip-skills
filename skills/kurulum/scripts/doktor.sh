#!/usr/bin/env bash
# Skill'lerin dayandığı araçları kontrol eder. Çıktı: tek satır/araç, OK | EKSIK | OPSIYONEL.
# Hiçbir şey kurmaz, hiçbir şeyi değiştirmez.
set -u
ok=0; eksik=0
kontrol() { # ad komut zorunlu(1/0) kurulum_notu
  local ad="$1" cmd="$2" zorunlu="$3" not="$4"
  if command -v "${cmd%% *}" >/dev/null 2>&1 && $cmd >/dev/null 2>&1; then
    printf 'OK        %-16s %s\n' "$ad" "$($cmd 2>/dev/null | head -1)"; ok=$((ok+1))
  elif [ "$zorunlu" = 1 ]; then
    printf 'EKSIK     %-16s %s\n' "$ad" "$not"; eksik=$((eksik+1))
  else
    printf 'OPSIYONEL %-16s %s\n' "$ad" "$not"
  fi
}
kontrol "git"            "git --version"                 1 "git-scm.com"
kontrol "gh"             "gh --version"                  0 "cli.github.com (PR inceleme için)"
if [ -n "$(ls *.sln *.slnx *.csproj 2>/dev/null)" ] || [ -n "$(find . -maxdepth 3 -name '*.csproj' 2>/dev/null | head -1)" ]; then
  kontrol "dotnet SDK"     "dotnet --version"              1 "dotnet.microsoft.com"
  kontrol "dotnet-ef"      "dotnet ef --version"           1 "dotnet tool install -g dotnet-ef"
  dv=$(dotnet --version 2>/dev/null | cut -d. -f1)
  if [ -n "$dv" ] && [ "$dv" -lt 10 ] 2>/dev/null; then printf 'UYARI     %-16s %s\n' "dotnet LTS" "SDK $dv.x; güncel LTS .NET 10 (8 ve 9 desteği 10.11.2026'da bitti/bitiyor)"; fi
  eski=$(grep -rhoE '<TargetFrameworks?>[^<]+' --include='*.csproj' . 2>/dev/null | grep -v 'net10\.0' | sort -u | head -3 | tr '\n' ' ')
  onizleme=$(dotnet --list-sdks 2>/dev/null | grep -Ei 'preview|rc|beta|alpha' | cut -d' ' -f1 | tr '\n' ' ')
  [ -n "$onizleme" ] && printf 'UYARI     %-16s %s\n' "önizleme SDK" "kaldırılmalı: $onizleme"
  [ -n "$eski" ] && printf 'UYARI     %-16s %s\n' "hedef çerçeve" "LTS dışı: $eski"
  kontrol "dotnet-counters" "dotnet-counters --version"    0 "dotnet tool install -g dotnet-counters (hata-ayikla)"
  kontrol "docker"         "docker --version"              0 "yayin: imaj üretimi"
fi
if [ -n "$(find . -maxdepth 3 -name pubspec.yaml 2>/dev/null | head -1)" ]; then
  kontrol "flutter"        "flutter --version"             1 "flutter.dev"
  kontrol "dart"           "dart --version"                1 "Flutter SDK ile gelir"
  kontrol "adb"            "adb --version"                 0 "Android SDK platform-tools"
  [ "$(uname)" = "Darwin" ] && kontrol "xcodebuild" "xcodebuild -version" 0 "iOS derlemesi için Xcode"
fi
printf '\n%d OK, %d EKSIK\n' "$ok" "$eksik"
[ "$eksik" -eq 0 ]
