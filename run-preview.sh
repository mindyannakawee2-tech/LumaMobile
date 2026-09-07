#!/usr/bin/env bash

set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BIN="$(find "$ROOT/shell/build" -type f -name lumashell -executable -print -quit 2>/dev/null)"

if [ -z "$BIN" ]; then
    echo "LumaShell is not built yet."
    echo
    echo "Run:"
    echo "  ./setup.sh"
    exit 1
fi


exec "$BIN"
