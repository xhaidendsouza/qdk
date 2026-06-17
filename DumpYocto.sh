#!/bin/bash
set -euo pipefail
CACHE_DIR="$(npm config get cache)/_cacache"

# Parse the integrity hash from the index
HASH=$(grep -rh "yocto-queue" "$CACHE_DIR/index-v5/" | \
       grep -o '"integrity":"[^"]*"' | head -1 | \
       sed 's/"integrity":"//;s/"//')

echo "Integrity: $HASH"

# Extract algo and base64 value
if [ -z "$HASH" ]; then
    echo "yocto-queue not found in npm cache"
    exit 1
fi

ALGO="${HASH%%-*}"   # e.g. sha512
B64="${HASH#*-}"

# Convert base64 to hex path: first 2 chars / next 2 chars / rest
HEX=$(echo "$B64" | base64 -d | xxd -p | tr -d '\n')
SUBDIR="${HEX:0:2}/${HEX:2:2}/${HEX:4}"
BLOB="$CACHE_DIR/content-v2/$ALGO/$SUBDIR"

echo "Blob path: $BLOB"
echo ""
if [ -f "$BLOB" ]; then
    echo "=== First 64 bytes ==="
    od -c -N 64 "$BLOB"
else
    echo "Blob not found at expected path, searching..."
    while read -r f; do
        if od -c -N 64 "$f" | grep -q "yocto"; then
            echo "Found: $f"
            od -c -N 64 "$f"
            break
        fi
    done < <(find "$CACHE_DIR/content-v2" -type f)
fi
