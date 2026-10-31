#!/usr/bin/env bash
set -euo pipefail
if (( $# != 2 )); then
    printf 'Использование: bash archive_memory.sh ФАЙЛ_СТАТИСТИКИ КАТАЛОГ_АРХИВОВ\n' >&2
    exit 2
fi
stat_path=$(realpath -e -- "$1")
mkdir -p -- "$2"
out_dir=$(realpath -e -- "$2")
# mktemp обеспечивает уникальность при ручных повторных проверках.
archive=$(mktemp "$out_dir/stat_$(date +%Y%m%d_%H%M%S)_XXXXXX.tar.gz")
tar -czf "$archive" -C "$(dirname -- "$stat_path")" -- "$(basename -- "$stat_path")"
tar -tzf "$archive" >/dev/null
printf '%s\n' "$archive"
