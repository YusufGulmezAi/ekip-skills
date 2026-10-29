#!/usr/bin/env bash
set -eu
cp -R "$(dirname "$0")/files/." .
# Senaryonun git geçmişi depoda _git olarak saklanır (iç içe .git, dış depoya girmez).
if [ -d _git ]; then mv _git .git; fi
