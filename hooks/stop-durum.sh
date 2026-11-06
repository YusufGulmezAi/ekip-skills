#!/usr/bin/env bash
# Stop hook: çalışma ağacında değişiklik varken docs/agent/durum.md güncel değilse Claude'u durdurmaz,
# önce durumu yazmasını ister. Döngü koruması: stop_hook_active true ise hiçbir şey yapmaz.
# Ani kesintiye karşı tek güvence budur: durum her turun sonunda yazılmış olur.
set -u
girdi=$(cat 2>/dev/null || true)
case "$girdi" in *'"stop_hook_active": true'*|*'"stop_hook_active":true'*) exit 0;; esac

PROJE="${CLAUDE_PROJECT_DIR:-$PWD}"
git -C "$PROJE" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
degisen=$(git -C "$PROJE" status --porcelain 2>/dev/null | awk '{print $2}')
[ -z "$degisen" ] && exit 0

DURUM_REL="docs/agent/durum.md"
[ -f "$PROJE/$DURUM_REL" ] || [ ! -f "$PROJE/docs/DURUM.md" ] || DURUM_REL="docs/DURUM.md"
DURUM="$PROJE/$DURUM_REL"
mtime() { stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo 0; }
durum_t=0; [ -f "$DURUM" ] && durum_t=$(mtime "$DURUM")
en_yeni=0
for f in $degisen; do
  [ "$f" = "$DURUM_REL" ] && continue
  t=$(mtime "$PROJE/$f"); [ "$t" -gt "$en_yeni" ] && en_yeni=$t
done
[ "$en_yeni" -le "$durum_t" ] && exit 0

sayi=$(printf '%s\n' "$degisen" | grep -vcx "$DURUM_REL")
printf '{"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":"Bitirmeden önce %s dosyasını güncelle: commit edilmemiş %s dosya var ve durum dosyası bu değişikliklerden eski. Yaz: şu an hangi görev, son doğrulanan adım (komut ve sonuç), sonraki adım, açık sorular, commit edilmemiş dosyalar. 30 satırı geçme. Sonra bitirebilirsin."}}\n' "$DURUM_REL" "$sayi"
exit 0
