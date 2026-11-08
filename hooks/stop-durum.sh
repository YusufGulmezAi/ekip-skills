#!/usr/bin/env bash
# Stop hook: bu oturumda dosya değiştiyse ve durum dosyası bu değişikliklerden eskiyse Claude'u durdurmaz,
# önce durumu yazmasını ister. Ani kesintiye karşı tek güvence budur: durum her turun sonunda yazılmış olur.
# Sessiz kaldığı durumlar: döngü koruması (stop_hook_active), git dışı, ne proje profili ne durum dosyası
# varsa (eklenti bu projede kurulmamış), oturum işareti yoksa (ilk tur işareti açar), oturumda değişiklik yoksa.
set -u
girdi=$(cat 2>/dev/null || true)
case "$girdi" in *'"stop_hook_active": true'*|*'"stop_hook_active":true'*) exit 0;; esac
. "$(dirname "$0")/ortak.sh"

PROJE="${CLAUDE_PROJECT_DIR:-$PWD}"
git -C "$PROJE" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

DURUM_REL=$(durum_yolu "$PROJE")
DURUM="$PROJE/$DURUM_REL"
profil_dosyasi "$PROJE" >/dev/null || [ -f "$DURUM" ] || exit 0

# Yalnız bu oturumda değişen dosyalar sayılır; başlangıç zamanı SessionStart'ta yazılır.
kimlik=$(oturum_kimligi "$girdi"); [ -n "$kimlik" ] || exit 0
isaret=$(oturum_isareti "$PROJE" "$kimlik") || exit 0
if [ ! -f "$isaret" ]; then
  mkdir -p "$(dirname "$isaret")" && date +%s > "$isaret"
  exit 0
fi

# İşaretin değişme zamanı oturum başıdır. İzlenmeyen klasör ("?? docs/") klasör olarak değil, içindeki
# dosyalarla değerlendirilir; klasörün kendi zamanı ve durum dosyası sayılmaz.
oturumda=$(git -C "$PROJE" status --porcelain 2>/dev/null | awk '{print $2}' | while IFS= read -r f; do
  yol="$PROJE/${f%/}"
  if [ -d "$yol" ]; then find "$yol" -type f -newer "$isaret" 2>/dev/null | head -n 200
  elif [ -e "$yol" ] && [ "$yol" -nt "$isaret" ]; then printf '%s\n' "$yol"; fi
done | grep -vxF "$DURUM")
[ -z "$oturumda" ] && exit 0
eski=0
while IFS= read -r g; do
  [ -f "$DURUM" ] && [ ! "$g" -nt "$DURUM" ] && continue
  eski=1; break
done <<< "$oturumda"
[ "$eski" -eq 0 ] && exit 0
sayi=$(printf '%s\n' "$oturumda" | wc -l | tr -d ' ')

printf '{"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":"Bitirmeden önce %s dosyasını güncelle: bu oturumda %s dosya değişti ve durum dosyası bu değişikliklerden eski. Yaz: şu an hangi görev, son doğrulanan adım (komut ve sonuç), sonraki adım, açık sorular, commit edilmemiş dosyalar. Projenin durum dosyası kuralına uy (yoksa ≤ 30 satır). Kullanıcı bu oturumda yalnız belirli dosyaları yazmanı istediyse (ör. '"'"'tek dosya yaz'"'"') durum dosyasına dokunma; bunu bir cümleyle söyle ve bitir. Sonra bitirebilirsin."}}\n' "$DURUM_REL" "$sayi"
exit 0
