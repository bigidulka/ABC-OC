#!/usr/bin/env bash
set -euo pipefail
if (( $# != 1 )); then
    printf 'Использование: bash memory_stat.sh ФАЙЛ_СТАТИСТИКИ\n' >&2
    exit 2
fi
mkdir -p -- "$(dirname -- "$1")"
# Одна строка Mem, без заголовка и Swap. Значения в байтах.
LC_ALL=C free -b | awk '$1 == "Mem:" {for(i=2;i<=NF;i++) printf "%s%s", $i, (i==NF ? ORS : OFS)}' >> "$1"
