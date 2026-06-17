#!/bin/bash
set -e

path="$1"

echo "=== Keys ==="
while IFS= read -r line; do
    if [[ "$line" == *=* ]]; then
        key="${line%%=*}"
        echo "${key## }"| sed 's/[[:space:]]*$//'
    fi
done < "$path"

echo "=== URLs ==="
while IFS= read -r line; do
    if [[ "$line" == *dev.azure.com* ]]; then
        echo "$line"
    fi
done < "$path"
