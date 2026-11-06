#!/usr/bin/env bash
# Oturum başında (startup | clear | compact) çekirdek kuralları ve varsa "kaldığın yer" dosyasını bağlama ekler.
# Hızlı ve hatasız olmalı; eksik dosya sessizce atlanır.
set -u
KOK="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
PROJE="${CLAUDE_PROJECT_DIR:-$PWD}"
RULES="$KOK/rules/cekirdek.md"
DURUM="$PROJE/docs/agent/durum.md"; [ -r "$DURUM" ] || DURUM="$PROJE/docs/DURUM.md"

{
  [ -r "$RULES" ] && cat "$RULES"
  if [ -r "$DURUM" ]; then
    printf '\n\n# Kaldığın yer (%s)\n' "${DURUM#$PROJE/}"
    head -c 2500 "$DURUM"
    if git -C "$PROJE" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      dal=$(git -C "$PROJE" branch --show-current 2>/dev/null)
      kirli=$(git -C "$PROJE" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
      printf '\n\nGit: dal `%s`, commit edilmemiş %s dosya. İşe başlamadan `ekip-skills:devam` ile durumu doğrula.\n' "${dal:-?}" "$kirli"
    fi
  fi
}
exit 0
