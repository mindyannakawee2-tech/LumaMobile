#!/usr/bin/env bash

set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT" || exit 1

say() {
    printf '\n%s\n' "$1"
}

have_pkg() {
    apt-cache show "$1" >/dev/null 2>&1
}

add_if_available() {
    if have_pkg "$1"; then
        PACKAGES+=("$1")
    fi
}

say "============================================================"
say " LumaMobile Setup"
say "============================================================"

printf 'Repository: %s\n' "$ROOT"

if ! command -v apt-get >/dev/null 2>&1; then
    cat <<'EOF'

This setup script currently supports Debian-family systems such as:
  - Linux Mint
  - Ubuntu
  - Debian

Other distributions can still build LumaMobile, but dependencies must be
installed manually for now.
EOF
    exit 1
fi

say "[1/5] Installing development dependencies..."

sudo apt-get update

PACKAGES=(
    git
    build-essential
    cmake
    ninja-build
    pkg-config
    python3
    python3-gi
    qemu-system-x86
    qemu-utils
    qt6-base-dev
    qt6-declarative-dev
)

# QML runtime modules. Package availability differs slightly between
# Debian/Ubuntu/Mint releases, so only install modules that exist.
add_if_available qml6-module-qtquick
add_if_available qml6-module-qtquick-window
add_if_available qml6-module-qtquick-layouts
add_if_available qml6-module-qtquick-controls
add_if_available qml6-module-qtquick-templates
add_if_available qml6-module-qtqml
add_if_available qml6-module-qtqml-workerscript

# LumaVM frontend dependencies.
add_if_available gir1.2-gtk-3.0
add_if_available gir1.2-gtkvnc-2.0
add_if_available gir1.2-gtk-vnc-2.0
add_if_available libgtk-vnc-2.0-0

sudo apt-get install -y "${PACKAGES[@]}"

say "[2/5] Building LumaShell host preview..."

cmake \
    -S "$ROOT/shell" \
    -B "$ROOT/shell/build" \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release

cmake --build "$ROOT/shell/build"

say "[3/5] Building Luma Framework + LMS tools..."

mkdir -p \
    "$ROOT/build/host/bin" \
    "$ROOT/build/host/lib" \
    "$ROOT/build/host/obj"

cc -O2 -std=c11 -pthread \
    -I"$ROOT/framework/include" \
    "$ROOT/framework/src/lumad.c" \
    -o "$ROOT/build/host/bin/lumad"

cc -O2 -std=c11 \
    -I"$ROOT/framework/include" \
    "$ROOT/framework/src/lumactl.c" \
    -o "$ROOT/build/host/bin/lumactl"

cc -O2 -std=c11 -pthread \
    -I"$ROOT/framework/include" \
    -I"$ROOT/services/lms/include" \
    "$ROOT/services/lms/src/lmsd.c" \
    -o "$ROOT/build/host/bin/lmsd"

cc -O2 -std=c11 \
    -I"$ROOT/framework/include" \
    -I"$ROOT/services/lms/include" \
    "$ROOT/services/lms/src/lmsctl.c" \
    -o "$ROOT/build/host/bin/lmsctl"

say "[4/5] Building Luma C++ SDK..."

g++ -O2 -std=c++17 \
    -I"$ROOT/sdk/cpp/include" \
    -I"$ROOT/framework/include" \
    -I"$ROOT/services/lms/include" \
    -c "$ROOT/sdk/cpp/src/Luma.cpp" \
    -o "$ROOT/build/host/obj/Luma.o"

ar rcs \
    "$ROOT/build/host/lib/libluma.a" \
    "$ROOT/build/host/obj/Luma.o"

say "[5/5] Finalizing..."

chmod +x \
    "$ROOT/run-preview.sh" \
    "$ROOT/tools/lumavm/lumavm" \
    "$ROOT/scripts/"*.sh \
    "$ROOT/tools/lpk/lpk-pack" \
    2>/dev/null || true

cat <<EOF

============================================================
 LumaMobile setup complete ✓
============================================================

Try the desktop-host preview now:

  ./run-preview.sh

Built host tools:

  build/host/bin/lumad
  build/host/bin/lumactl
  build/host/bin/lmsd
  build/host/bin/lmsctl
  build/host/lib/libluma.a

NOTE:
The host preview is for trying and developing LumaShell on a normal Linux
machine. The full LumaVM boot currently also needs generated OS artifacts
(kernel, initramfs and data disk) that are intentionally not committed to Git.

EOF
