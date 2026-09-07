#!/usr/bin/env bash

ROOT="$HOME/LumaMobile"
SHELLDIR="$ROOT/shell"

BIN="$(
    find "$SHELLDIR/build" \
        -type f \
        -name lumashell \
        -executable \
        -print \
        -quit
)"

if [ -z "$BIN" ]; then

    echo "ERROR: LumaShell has not been built."

    exit 1
fi


LOG="$SHELLDIR/runtime.log"

rm -f "$LOG"


nohup "$BIN" \
    > "$LOG" \
    2>&1 \
    < /dev/null &


PID=$!


echo
echo "LumaShell launched."
echo
echo "PID:"
echo "  $PID"
echo
echo "Runtime log:"
echo "  $LOG"
echo

sleep 2


if kill -0 "$PID" 2>/dev/null
then

    echo "✓ LumaShell is running"

else

    echo "✗ LumaShell exited"
    echo
    echo "Runtime error:"
    echo

    cat "$LOG"

    exit 1
fi
