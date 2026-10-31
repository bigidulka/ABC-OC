#!/usr/bin/env bash
set -euo pipefail
if (( $# != 2 )); then
    printf 'Использование: bash sum.sh ЦЕЛОЕ1 ЦЕЛОЕ2\n' >&2
    exit 2
fi
# Ограничение в 18 цифр гарантирует отсутствие переполнения суммы int64.
to_decimal() {
    local value=$1 sign=1
    if [[ ! $value =~ ^[+-]?[0-9]{1,18}$ ]]; then
        printf 'Ожидается целое число длиной до 18 цифр: %s\n' "$value" >&2
        return 2
    fi
    case $value in
        -*) sign=-1; value=${value#-} ;;
        +*) value=${value#+} ;;
    esac
    printf '%s\n' "$((sign * 10#$value))"
}
first=$(to_decimal "$1")
second=$(to_decimal "$2")
result=$((first + second))
printf 'Сумма: %s\n' "$result"
if (( result < 0 )); then
    printf 'Результат меньше нуля\n'
elif (( result > 0 )); then
    printf 'Результат больше нуля\n'
else
    printf 'Результат равен нулю\n'
fi
