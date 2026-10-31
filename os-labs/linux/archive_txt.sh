#!/usr/bin/env bash
set -euo pipefail
if (( $# < 1 || $# > 3 )); then
    printf 'Использование: bash archive_txt.sh ПРЕФИКС [КАТАЛОГ_ИСТОЧНИКА] [КАТАЛОГ_АРХИВОВ]\n' >&2
    exit 2
fi
prefix=$1
case $prefix in
    ''|*/*|*$'\n'*|*$'\r'*) printf 'Префикс должен быть непустым именем без / и перевода строки\n' >&2; exit 2 ;;
esac
source_dir=${2:-$HOME}
output_dir=${3:-$PWD}
source_dir=$(realpath -e -- "$source_dir")
[[ -d $source_dir ]] || { printf 'Источник не является каталогом\n' >&2; exit 2; }
mkdir -p -- "$output_dir"
output_dir=$(realpath -e -- "$output_dir")
destination="$output_dir/${prefix}_$(date +%H_%M_%S).tar.gz"
listing=$(mktemp "$output_dir/.txt-list.XXXXXX")
partial=$(mktemp "$output_dir/.txt-archive.XXXXXX")
trap 'rm -f -- "$listing" "$partial"' EXIT
# Рекурсивно, только обычные файлы, без перехода по символьным ссылкам.
# NUL сохраняет имена с пробелами, переводами строки и начальным дефисом.
(
    cd -- "$source_dir"
    find . -type f -name '*.txt' -print0 | sort -z > "$listing"
    tar --create --gzip --file="$partial" --null --verbatim-files-from --files-from="$listing"
)
gzip -t -- "$partial"
# ln атомарно публикует собственный готовый архив и отказывает при совпадении имени.
if ! ln -- "$partial" "$destination"; then
    printf 'Архив с таким именем уже существует: %s\n' "$destination" >&2
    exit 1
fi
printf '%s\n' "$destination"
