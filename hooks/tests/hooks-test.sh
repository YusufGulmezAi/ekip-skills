#!/usr/bin/env bash
# Hook davranış testleri (Git Bash / WSL / macOS): bash hooks/tests/hooks-test.sh
# Her vaka geçici bir git deposu kurar; hook'ları gerçek girdileriyle (stdin JSON) çalıştırır.
set -u
KOK="$(cd "$(dirname "$0")/../.." && pwd)"
export CLAUDE_PLUGIN_ROOT="$KOK"
gecen=0; kalan=0
basari() { gecen=$((gecen + 1)); printf 'ok   %s\n' "$1"; }
hata() { kalan=$((kalan + 1)); printf 'HATA %s\n     %s\n' "$1" "$2"; }
simdi=$(date +%s)
PY=python3; "$PY" -c '' 2>/dev/null || PY=python  # Windows'ta python3 sahte başlatıcı olabilir

yeni_proje() {  # boş git deposu; CLAUDE_PROJECT_DIR olarak ayarlanır
  P=$(mktemp -d); export CLAUDE_PROJECT_DIR="$P"
  git -C "$P" init -q; git -C "$P" config user.email t@t; git -C "$P" config user.name t; git -C "$P" config core.autocrlf false
  echo ilk > "$P/a.txt"; git -C "$P" add a.txt; git -C "$P" commit -qm ilk
}
profil_yaz() { printf '# Proje\n\n## Proje profili\n- Ürün: deneme\n%s\n' "${1:-}" > "$P/CLAUDE.md"; touch -d "@$((simdi - 300))" "$P/CLAUDE.md"; }
durum_yaz() { mkdir -p "$(dirname "$P/$1")"; printf '# Durum\n**Şu an:** deneme\n' > "$P/$1"; touch -d "@$2" "$P/$1"; }
isaret_yaz() { local d; d="$(git -C "$P" rev-parse --absolute-git-dir)/ekip-skills"; mkdir -p "$d"; echo "$1" > "$d/oturum-s1"; touch -d "@$1" "$d/oturum-s1"; }
stop() { printf '{"session_id":"s1","stop_hook_active":%s}' "${1:-false}" | bash "$KOK/hooks/stop-durum.sh"; }
basla() { printf '{"session_id":"s1","source":"startup"}' | bash "$KOK/hooks/session-start.sh"; }
karakter() { LC_ALL=C tr -d '\200-\277' | wc -c | tr -d ' '; }

# --- Stop hook ---
yeni_proje; echo x >> "$P/a.txt"; isaret_yaz $((simdi - 100))
c=$(stop); [ -z "$c" ] && basari "stop: profil ve durum yoksa sessiz" || hata "stop: profil ve durum yoksa sessiz" "$c"

yeni_proje; profil_yaz; durum_yaz docs/agent/durum.md $((simdi - 300)); isaret_yaz $((simdi - 100))
echo x >> "$P/a.txt"; touch -d "@$((simdi - 200))" "$P/a.txt"
c=$(stop); [ -z "$c" ] && basari "stop: oturumdan önceki değişiklik sayılmaz" || hata "stop: oturumdan önceki değişiklik sayılmaz" "$c"

yeni_proje; profil_yaz; durum_yaz docs/agent/durum.md $((simdi - 300)); isaret_yaz $((simdi - 100))
echo x >> "$P/a.txt"; echo y > "$P/eski.txt"; touch -d "@$((simdi - 200))" "$P/eski.txt"
c=$(stop)
case "$c" in *docs/agent/durum.md*"bu oturumda 1 dosya"*) basari "stop: oturumdaki değişiklikte durum ister, yalnız oturum dosyalarını sayar";;
  *) hata "stop: oturumdaki değişiklikte durum ister, yalnız oturum dosyalarını sayar" "$c";; esac
case "$c" in *"durum dosyası kuralına uy (yoksa ≤ 30 satır)"*) basari "stop: sabit 30 satır yerine proje kuralı";;
  *) hata "stop: sabit 30 satır yerine proje kuralı" "$c";; esac
case "$c" in *"30 satırı geçme"*) hata "stop: eski sabit sınır kalktı" "$c";; *) basari "stop: eski sabit sınır kalktı";; esac
case "$c" in *"tek dosya yaz"*) basari "stop: kullanıcı talimatı durum isteğinin önüne geçer";;
  *) hata "stop: kullanıcı talimatı durum isteğinin önüne geçer" "$c";; esac
printf '%s' "$c" | "$PY" -c 'import json,sys; json.load(sys.stdin)' 2>/dev/null \
  && basari "stop: çıktı geçerli JSON" || hata "stop: çıktı geçerli JSON" "$c"

yeni_proje; profil_yaz; isaret_yaz $((simdi - 100)); echo x >> "$P/a.txt"; durum_yaz docs/agent/durum.md $((simdi + 3600))
c=$(stop); [ -z "$c" ] && basari "stop: durum güncelse sessiz" || hata "stop: durum güncelse sessiz" "$c"

yeni_proje; profil_yaz; durum_yaz docs/agent/durum.md $((simdi + 3600)); isaret_yaz $((simdi - 100))
echo z > "$P/docs/yeni.md"; touch -d "@$((simdi + 7200))" "$P/docs/yeni.md"
c=$(stop); case "$c" in *"bu oturumda 1 dosya"*) basari "stop: izlenmeyen klasördeki yeni dosya sayılır, durum sayılmaz";;
  *) hata "stop: izlenmeyen klasördeki yeni dosya sayılır, durum sayılmaz" "$c";; esac

yeni_proje; profil_yaz; isaret_yaz $((simdi - 100)); durum_yaz docs/agent/durum.md $((simdi - 50))
c=$(stop); [ -z "$c" ] && basari "stop: oturumda değişiklik yoksa sessiz" || hata "stop: oturumda değişiklik yoksa sessiz" "$c"

yeni_proje; profil_yaz '- Durum dosyası: `docs/DURUM.md` · Geliştirici kabuğu: PowerShell'
durum_yaz docs/DURUM.md $((simdi - 300)); isaret_yaz $((simdi - 100)); echo x >> "$P/a.txt"
c=$(stop); case "$c" in *docs/DURUM.md*) basari "stop: profildeki durum yolunu kullanır";;
  *) hata "stop: profildeki durum yolunu kullanır" "$c";; esac

yeni_proje; profil_yaz; echo x >> "$P/a.txt"
c=$(stop); d="$(git -C "$P" rev-parse --absolute-git-dir)/ekip-skills/oturum-s1"
[ -z "$c" ] && [ -f "$d" ] && basari "stop: oturum işareti yoksa sessiz, işareti açar" || hata "stop: oturum işareti yoksa sessiz, işareti açar" "$c"

yeni_proje; profil_yaz; isaret_yaz $((simdi - 100)); echo x >> "$P/a.txt"
c=$(stop true); [ -z "$c" ] && basari "stop: stop_hook_active iken sessiz" || hata "stop: stop_hook_active iken sessiz" "$c"

# --- SessionStart hook ---
yeni_proje; basla >/dev/null; d="$(git -C "$P" rev-parse --absolute-git-dir)/ekip-skills/oturum-s1"
[ -f "$d" ] && basari "başlangıç: oturum işaretini yazar" || hata "başlangıç: oturum işaretini yazar" "$d yok"

yeni_proje; durum_yaz docs/agent/durum.md "$simdi"
c=$(basla); case "$c" in *"**Şu an:** deneme"*) basari "başlangıç: küçük durum dosyası tam gelir";;
  *) hata "başlangıç: küçük durum dosyası tam gelir" "${c: -300}";; esac

yeni_proje; mkdir -p "$P/docs/agent"
{ echo '# Durum'; echo '## Biten işler'; echo '| Adım | Sonuç |'; echo '|---|---|'
  for i in $(seq 1 120); do echo "| IP-$i ağır şema işi çğüşıö | geçti, kanıt komutu çalıştı |"; done
  echo '## Sıradaki'; echo '- IP-121: arama sütunu geri dolumu'
  echo '## Açık sorular'; echo '- Şapka kuralı?'; echo '## Notlar'; echo '- son not'; } > "$P/docs/agent/durum.md"
c=$(basla)
case "$c" in *"IP-121: arama sütunu"*"Şapka kuralı?"*"| IP-1 ağır"*) basari "başlangıç: önce Sıradaki/Açık, sonra baştan";;
  *) hata "başlangıç: önce Sıradaki/Açık, sonra baştan" "${c: -400}";; esac
n=$(printf '%s' "$c" | karakter)
[ "$n" -le 10000 ] && basari "başlangıç: toplam çıktı ≤ 10.000 karakter ($n)" || hata "başlangıç: toplam çıktı ≤ 10.000 karakter" "$n"
[ "$n" -ge 9000 ] && basari "başlangıç: bütçe kullanılır ($n)" || hata "başlangıç: bütçe kullanılır" "$n"
case "$c" in *"| IP-120 "*) hata "başlangıç: uzun tablo kısaltılır" "IP-120 geldi";; *) basari "başlangıç: uzun tablo kısaltılır";; esac

yeni_proje; profil_yaz '- Durum dosyası: docs/DURUM.md'; durum_yaz docs/DURUM.md "$simdi"; durum_yaz docs/agent/durum.md "$simdi"
printf '**Şu an:** profildeki\n' >> "$P/docs/DURUM.md"
c=$(basla); case "$c" in *"Kaldığın yer (docs/DURUM.md)"*"profildeki"*) basari "başlangıç: profildeki durum yolunu kullanır";;
  *) hata "başlangıç: profildeki durum yolunu kullanır" "${c: -300}";; esac

printf '\n%s geçti, %s kaldı\n' "$gecen" "$kalan"
[ "$kalan" -eq 0 ]
