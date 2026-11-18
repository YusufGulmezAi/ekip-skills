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

# Proje, profildeki `ekip-skills: X.Y.Z` damgasıyla yüklü sürümün gerisindeyse aradaki sürümlerin proje etkisi
# (docs/proje-etkisi.md) ve `kurulum güncelle` önerisi. Profilsiz projede (eklenti kurulmamış) sessiz.
guncelleme_uyarisi() {
  local yuklu damga etki v
  profil_dosyasi "$PROJE" >/dev/null || return 0
  yuklu=$(yuklu_surum "$KOK"); [ -n "$yuklu" ] || return 0
  damga=$(proje_ekip_surumu "$PROJE")
  if [ -n "$damga" ] && ! surum_buyuk "$yuklu" "$damga"; then return 0; fi
  etki="$KOK/docs/proje-etkisi.md"
  printf '\n\n# ekip-skills güncellemesi\n'
  if [ -n "$damga" ]; then
    printf 'Bu proje ekip-skills %s ile kurulmuş; yüklü sürüm %s. Aradaki sürümlerin proje etkisi:\n' "$damga" "$yuklu"
  else
    printf 'Profilde ekip-skills sürüm damgası yok (yüklü %s). Sürümlerin proje etkisi:\n' "$yuklu"
  fi
  if [ -r "$etki" ]; then
    for v in $(grep -oE '^## [0-9]+\.[0-9]+\.[0-9]+' "$etki" | cut -c4-); do
      surum_buyuk "$v" "${damga:-0.0.0}" || continue
      surum_buyuk "$v" "$yuklu" && continue
      awk -v v="$v" '$0 == "## " v { a = 1; print "- " v ":"; next } /^## / { a = 0 } a && /^- / { print "  " $0 }' "$etki"
    done
  fi
  printf 'Kullanıcıya bunu bir cümleyle bildir ve `ekip-skills:kurulum güncelle` öner; proje dosyaları onaysız değiştirilmez, ADR ile çelişen madde uygulanmaz.\n'
}

# Satır sınırında en çok $1 karakter; kesilirse kaynağı söyler.
kisalt() {
  LC_ALL=C awk -v butce="$1" -v devam="$(printf '[\200-\277]')" '
    { t = $0; gsub(devam, "", t); n = length(t) + 1; if (top + n > butce) { kesik = 1; exit } top += n; print }
    END { if (kesik) print "…(devamı: eklentideki docs/proje-etkisi.md)" }'
}

on=""; [ -r "$RULES" ] && on=$(cat "$RULES")
uyari=$(guncelleme_uyarisi | kisalt 1500)
if [ ! -r "$DURUM" ]; then
  [ -n "$on" ] && printf '%s\n' "$on"
  [ -n "$uyari" ] && printf '%s\n' "$uyari"
  exit 0
fi
baslik=$(printf '\n\n# Kaldığın yer (%s)' "$DURUM_REL")
son=""
if git -C "$PROJE" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  dal=$(git -C "$PROJE" branch --show-current 2>/dev/null)
  kirli=$(git -C "$PROJE" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  son=$(printf '\n\nGit: dal `%s`, commit edilmemiş %s dosya. İşe başlamadan `ekip-skills:devam` ile durumu doğrula.' "${dal:-?}" "$kirli")
fi
sabit=$(printf '%s\n%s%s\n%s\n' "$on" "$uyari" "$baslik" "$son" | karakter)
butce=$((SINIR - sabit - 20))
[ -n "$uyari" ] && on=$(printf '%s\n%s' "$on" "$uyari")
printf '%s%s\n' "$on" "$baslik"
[ "$butce" -gt 0 ] && durum_ozeti "$DURUM" "$butce" "$DURUM_REL"
[ -n "$son" ] && printf '%s\n' "$son"
exit 0
