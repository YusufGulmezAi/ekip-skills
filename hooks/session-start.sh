#!/usr/bin/env bash
# Oturum başında (startup | resume | clear | compact) çekirdek kuralları ve varsa "kaldığın yer" dosyasını bağlama ekler,
# Stop hook'u için oturum başı zaman damgasını yazar. Hızlı ve hatasız olmalı; eksik dosya sessizce atlanır.
# Toplam çıktı ≤ 10.000 karakter (Claude Code sınırı). Durum dosyası sığmazsa önce Sıradaki/Sonraki/Açık başlıklı
# bölümler, sonra kalan bütçeyle baştan verilir; kesim satır sınırında yapılır.
set -u
girdi=$(cat 2>/dev/null || true)
KOK="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
. "$KOK/hooks/ortak.sh"
PROJE="${CLAUDE_PROJECT_DIR:-$PWD}"
RULES="$KOK/rules/cekirdek.md"
DURUM_REL=$(durum_yolu "$PROJE")
DURUM="$PROJE/$DURUM_REL"
SINIR=10000

# Oturum işareti: aynı oturumda (resume/compact) ilk zaman korunur; 7 günden eski işaretler silinir.
kimlik=$(oturum_kimligi "$girdi")
if [ -n "$kimlik" ] && isaret=$(oturum_isareti "$PROJE" "$kimlik"); then
  mkdir -p "$(dirname "$isaret")" 2>/dev/null && { [ -f "$isaret" ] || date +%s > "$isaret"; }
  find "$(dirname "$isaret")" -name 'oturum-*' -mtime +7 -delete 2>/dev/null
fi

karakter() { LC_ALL=C tr -d '\200-\277' | wc -c | tr -d ' '; }  # UTF-8 karakter sayısı

# $1 dosya, $2 bütçe (karakter). Sığarsa tamamı; sığmazsa öncelikli bölümler + baştan, satır sınırında.
durum_ozeti() {
  LC_ALL=C awk -v butce="$2" -v ad="$3" -v devam="$(printf '[\200-\277]')" '
    function uz(s,  t) { t = s; gsub(devam, "", t); return length(t) + 1 }
    { satir[NR] = $0; toplam += uz($0) }
    END {
      if (toplam <= butce) { for (i = 1; i <= NR; i++) print satir[i]; exit }
      ic = 0
      for (i = 1; i <= NR; i++) {
        if (satir[i] ~ /^#+[ \t]/) {
          match(satir[i], /^#+/); sv = RLENGTH
          if (ic && sv <= icsv) ic = 0
          if (!ic && satir[i] ~ /(Sıradaki|sıradaki|SIRADAKİ|Sonraki|sonraki|SONRAKİ|Açık|açık|AÇIK)/) { ic = 1; icsv = sv }
        }
        onc[i] = ic
      }
      ayrac = "…(öncelikli bölümler yukarıda; baştan devam)…"
      kalan = butce - uz(ayrac) - 120
      for (i = 1; i <= NR; i++) if (onc[i]) { if (uz(satir[i]) > kalan) break; print satir[i]; kalan -= uz(satir[i]); yaz[i] = 1 }
      print ayrac
      for (i = 1; i <= NR; i++) if (!onc[i]) { if (uz(satir[i]) > kalan) break; print satir[i]; kalan -= uz(satir[i]); yaz[i] = 1 }
      eksik = 0; for (i = 1; i <= NR; i++) if (!yaz[i]) eksik++
      printf "[Kısaltıldı: %d satır gösterilmedi; tamamı %s]\n", eksik, ad
    }' "$1"
}

on=""; [ -r "$RULES" ] && on=$(cat "$RULES")
if [ ! -r "$DURUM" ]; then
  [ -n "$on" ] && printf '%s\n' "$on"
  exit 0
fi
baslik=$(printf '\n\n# Kaldığın yer (%s)' "$DURUM_REL")
son=""
if git -C "$PROJE" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  dal=$(git -C "$PROJE" branch --show-current 2>/dev/null)
  kirli=$(git -C "$PROJE" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  son=$(printf '\n\nGit: dal `%s`, commit edilmemiş %s dosya. İşe başlamadan `ekip-skills:devam` ile durumu doğrula.' "${dal:-?}" "$kirli")
fi
sabit=$(printf '%s%s\n%s\n' "$on" "$baslik" "$son" | karakter)
butce=$((SINIR - sabit - 20))
printf '%s%s\n' "$on" "$baslik"
[ "$butce" -gt 0 ] && durum_ozeti "$DURUM" "$butce" "$DURUM_REL"
[ -n "$son" ] && printf '%s\n' "$son"
exit 0
