#!/usr/bin/env bash
# Kapsamı değişen koda dokunan ve son_dogrulama tarihi o koddan eski olan dokümanları listeler.
# Kullanım: bayat.sh [taban-ref]   (varsayılan: origin/main, yoksa HEAD~10)
# Çıktı: "BAYAT <doküman> <son_dogrulama> <değişen dosya>" satırları; hiç yoksa "bayat doküman yok".
set -u
taban="${1:-}"
if [ -z "$taban" ]; then
  if git rev-parse --verify -q origin/main >/dev/null; then taban="origin/main"; else taban="HEAD~10"; fi
fi
degisen=$(git diff --name-only "$taban"...HEAD 2>/dev/null; git diff --name-only HEAD 2>/dev/null) || exit 0
[ -z "$degisen" ] && { echo "değişen dosya yok"; exit 0; }
bulundu=0
for doc in $(find docs -name '*.md' 2>/dev/null); do
  kapsam=$(grep -m1 -E '^kapsam:' "$doc" | sed -E 's/^kapsam:\s*\[?//; s/\]?\s*$//')
  tarih=$(grep -m1 -oE '^son_dogrulama:\s*[0-9]{4}-[0-9]{2}-[0-9]{2}' "$doc" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
  [ -z "$kapsam" ] && continue
  IFS=',' read -ra terimler <<< "$kapsam"
  for t in "${terimler[@]}"; do
    t=$(echo "$t" | sed -E 's/^\s+|\s+$//g' | tr -d '"'"'"'')
    [ -z "$t" ] && continue
    anahtar=$(echo "$t" | tr 'İIŞĞÜÖÇ' 'iisguoc' | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]//g')
    for f in $degisen; do
      fk=$(echo "$f" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]//g')
      case "$fk" in *"$anahtar"*)
        son=$(git log -1 --format=%cs -- "$f" 2>/dev/null)
        if [ -z "$tarih" ] || [ -z "$son" ] || [[ "$son" > "$tarih" ]]; then
          echo "BAYAT $doc ${tarih:-tarihsiz} $f"; bulundu=1
        fi;;
      esac
    done
  done
done
[ "$bulundu" -eq 0 ] && echo "bayat doküman yok"
exit 0
