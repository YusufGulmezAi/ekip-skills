#!/usr/bin/env bash
# Hook'ların ortak yardımcıları: proje profili, durum dosyası yolu, oturum işareti.
# Kaynak olarak yüklenir (`. ortak.sh`); kendi başına bir şey yapmaz.

# Proje profilini taşıyan dosya (`## Proje profili` başlığı olan CLAUDE.md); yoksa 1 döner.
profil_dosyasi() {
  local f
  for f in "$1/CLAUDE.md" "$1/.claude/CLAUDE.md"; do
    grep -qs '^## Proje profili' "$f" && { printf '%s' "$f"; return 0; }
  done
  return 1
}

# Durum dosyasının proje köküne göre yolu (dosya henüz olmayabilir).
# Sıra: profildeki "Durum dosyası:" satırı → docs/agent/durum.md → docs/DURUM.md.
durum_yolu() {
  local p yol
  if p=$(profil_dosyasi "$1"); then
    yol=$(grep -m1 'Durum dosyası:' "$p" | sed 's/.*Durum dosyası:[[:space:]]*//; s/[[:space:]]*·.*//; s/[`*]//g; s/[[:space:]]*$//')
    case "$yol" in ''|*'<'*|*'|'*|*' '*) ;; *) printf '%s' "$yol"; return 0;; esac  # boş ya da şablon değeri
  fi
  if [ -f "$1/docs/agent/durum.md" ] || [ ! -f "$1/docs/DURUM.md" ]; then
    printf 'docs/agent/durum.md'
  else
    printf 'docs/DURUM.md'
  fi
}

# Hook girdisindeki (stdin JSON) session_id; güvenli karakterlere indirgenir.
oturum_kimligi() {
  printf '%s' "$1" | grep -o '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -n1 \
    | sed 's/.*"\([^"]*\)"$/\1/' | tr -cd 'A-Za-z0-9_-'
}

# Oturum başı zaman damgasının tutulduğu dosya (.git içinde, depoya girmez).
oturum_isareti() {
  local gd
  gd=$(git -C "$1" rev-parse --absolute-git-dir 2>/dev/null) || return 1
  printf '%s/ekip-skills/oturum-%s' "$gd" "$2"
}

