#!/usr/bin/env bash

ROOT="$HOME/LumaMobile"

TARGET="$ROOT/targets/rpi4-xpt2046"

CACHE="$ROOT/cache/rpi4"

OUTPUT="$ROOT/output"

LOGS="$ROOT/logs"

MNT="$ROOT/.mnt-rpi4"

BASE_DOWNLOAD="$CACHE/raspios-arm64-latest"

BASE_DIR="$CACHE/base"

WORK_IMG="$OUTPUT/LumaMobile-rpi4-working.img"

FINAL_IMG="$OUTPUT/LumaMobile-rpi4.img"


# ============================================================
# Helpers
# ============================================================

say()
{
    echo
    echo "============================================================"
    echo " $*"
    echo "============================================================"
}


die()
{
    echo
    echo "✗ $*"
    echo
    echo "Build stopped safely."
    exit 1
}


cleanup()
{
    sync 2>/dev/null || true

    if mountpoint -q "$MNT/run" 2>/dev/null; then
        sudo umount -R "$MNT/run" 2>/dev/null || true
    fi

    if mountpoint -q "$MNT/dev" 2>/dev/null; then
        sudo umount -R "$MNT/dev" 2>/dev/null || true
    fi

    if mountpoint -q "$MNT/sys" 2>/dev/null; then
        sudo umount "$MNT/sys" 2>/dev/null || true
    fi

    if mountpoint -q "$MNT/proc" 2>/dev/null; then
        sudo umount "$MNT/proc" 2>/dev/null || true
    fi

    if mountpoint -q "$MNT/boot/firmware" 2>/dev/null; then
        sudo umount "$MNT/boot/firmware" 2>/dev/null || true
    fi

    if mountpoint -q "$MNT" 2>/dev/null; then
        sudo umount "$MNT" 2>/dev/null || true
    fi

    if [ -n "${LOOPDEV:-}" ]; then
        sudo losetup -d "$LOOPDEV" 2>/dev/null || true
    fi
}


trap cleanup EXIT INT TERM


# ============================================================
# Read target config
# ============================================================

[ -f "$TARGET/target.env" ] \
    || die "Missing target.env"

# shellcheck disable=SC1090
source "$TARGET/target.env"


say "LumaMobile ARM64 Builder"

echo "Target:"
echo "  $LUMA_TARGET"

echo
echo "Display:"
echo "  $LUMA_LCD_DRIVER"
echo "  rotation $LUMA_LCD_ROTATE"

echo
echo "Touch:"
echo "  XPT2046 / ADS7846"
echo "  IRQ GPIO $LUMA_TOUCH_IRQ"


# ============================================================
# Check source
# ============================================================

[ -d "$ROOT/shell" ] \
    || die "Missing LumaShell source"

[ -f "$ROOT/shell/CMakeLists.txt" ] \
    || die "Missing shell/CMakeLists.txt"

[ -d "$ROOT/framework" ] \
    || die "Missing Luma Framework"

[ -d "$ROOT/services/lms" ] \
    || die "Missing LMS source"


# ============================================================
# Host dependencies
# ============================================================

say "1/10 Installing ARM build tools"

sudo apt update

sudo apt install -y \
    curl \
    unzip \
    xz-utils \
    file \
    rsync \
    parted \
    e2fsprogs \
    dosfstools \
    util-linux \
    qemu-user-static \
    binfmt-support \
    ca-certificates

if [ "$?" -ne 0 ]; then
    die "Could not install host dependencies"
fi


mkdir -p \
    "$CACHE" \
    "$BASE_DIR" \
    "$OUTPUT" \
    "$LOGS"


# ============================================================
# Download Raspberry Pi ARM64 bootable base
#
# We use Raspberry Pi OS Lite only as:
#
#   - Pi firmware
#   - bootloader files
#   - Raspberry Pi kernel
#   - ARM64 base runtime
#
# LumaShell becomes the actual graphical environment.
# ============================================================

say "2/10 Getting Raspberry Pi ARM64 base"

BASE_URL="https://downloads.raspberrypi.com/raspios_lite_arm64_latest"


if [ ! -f "$BASE_DOWNLOAD" ]; then

    echo "Downloading Raspberry Pi OS Lite ARM64..."

    curl \
        -L \
        --fail \
        --progress-bar \
        "$BASE_URL" \
        -o "$BASE_DOWNLOAD"

    if [ "$?" -ne 0 ]; then
        die "Base-image download failed"
    fi

else

    echo "✓ cached base image found"

fi


TYPE="$(
    file \
        -b \
        "$BASE_DOWNLOAD"
)"


echo
echo "Downloaded format:"
echo "  $TYPE"


rm -rf "$BASE_DIR"

mkdir -p "$BASE_DIR"


case "$TYPE" in

    *Zip*)

        unzip \
            -o \
            "$BASE_DOWNLOAD" \
            -d "$BASE_DIR" \
            >/dev/null

        ;;

    *XZ*|*XZ\ compressed*)

        xz \
            -dc \
            "$BASE_DOWNLOAD" \
            > "$BASE_DIR/base.img"

        ;;

    *)

        cp \
            "$BASE_DOWNLOAD" \
            "$BASE_DIR/base.img"

        ;;

esac


BASE_IMG="$(
    find "$BASE_DIR" \
        -maxdepth 2 \
        -type f \
        -name '*.img' \
        -print \
        | head -1
)"


[ -n "$BASE_IMG" ] \
    || die "Could not locate Raspberry Pi image"


echo
echo "✓ Base:"
echo "  $BASE_IMG"


# ============================================================
# Create working image
# ============================================================

say "3/10 Creating LumaMobile image"

rm -f \
    "$WORK_IMG" \
    "$FINAL_IMG"


cp --reflink=auto \
    "$BASE_IMG" \
    "$WORK_IMG"


# Give us plenty of room for Qt and build tools.
#
# This increases the image file by 6 GB but creates sparse
# space on filesystems that support sparse files.

truncate \
    -s +6G \
    "$WORK_IMG"


echo "Expanding root partition..."

sudo parted \
    -s \
    "$WORK_IMG" \
    resizepart \
    2 \
    100%


LOOPDEV="$(
    sudo losetup \
        --find \
        --show \
        --partscan \
        "$WORK_IMG"
)"


[ -n "$LOOPDEV" ] \
    || die "Could not create loop device"


echo "Loop:"
echo "  $LOOPDEV"


ROOTPART="${LOOPDEV}p2"
BOOTPART="${LOOPDEV}p1"


[ -b "$ROOTPART" ] \
    || die "Root partition not found"

[ -b "$BOOTPART" ] \
    || die "Boot partition not found"


echo
echo "Expanding ext4 filesystem..."


sudo e2fsck \
    -f \
    -y \
    "$ROOTPART" \
    >/dev/null


sudo resize2fs \
    "$ROOTPART" \
    >/dev/null


# ============================================================
# Mount image
# ============================================================

say "4/10 Mounting ARM filesystem"

sudo rm -rf "$MNT"

mkdir -p "$MNT"


sudo mount \
    "$ROOTPART" \
    "$MNT"


sudo mkdir -p \
    "$MNT/boot/firmware"


sudo mount \
    "$BOOTPART" \
    "$MNT/boot/firmware"


echo "✓ root mounted"
echo "✓ boot mounted"


# ============================================================
# ARM chroot
# ============================================================

say "5/10 Preparing ARM64 build environment"


sudo cp \
    /usr/bin/qemu-aarch64-static \
    "$MNT/usr/bin/"


sudo mount \
    -t proc \
    proc \
    "$MNT/proc"


sudo mount \
    -t sysfs \
    sys \
    "$MNT/sys"


sudo mount \
    --rbind \
    /dev \
    "$MNT/dev"


sudo mount \
    --make-rslave \
    "$MNT/dev"


sudo mount \
    --rbind \
    /run \
    "$MNT/run"


sudo mount \
    --make-rslave \
    "$MNT/run"


sudo cp \
    /etc/resolv.conf \
    "$MNT/etc/resolv.conf"


# Prevent package installation from trying to start daemons
# inside the chroot.

sudo tee \
    "$MNT/usr/sbin/policy-rc.d" \
    >/dev/null <<'EOF'
#!/bin/sh
exit 101
EOF


sudo chmod +x \
    "$MNT/usr/sbin/policy-rc.d"


# ============================================================
# Copy LumaMobile source
# ============================================================

sudo mkdir -p \
    "$MNT/opt/lumamobile-src"


sudo rsync \
    -a \
    --delete \
    "$ROOT/shell/" \
    "$MNT/opt/lumamobile-src/shell/"


sudo rsync \
    -a \
    --delete \
    "$ROOT/framework/" \
    "$MNT/opt/lumamobile-src/framework/"


sudo mkdir -p \
    "$MNT/opt/lumamobile-src/services"


sudo rsync \
    -a \
    --delete \
    "$ROOT/services/lms/" \
    "$MNT/opt/lumamobile-src/services/lms/"


# ============================================================
# Install ARM64 Qt/runtime
# ============================================================

say "6/10 Installing ARM64 Qt 6"

sudo chroot \
    "$MNT" \
    /usr/bin/qemu-aarch64-static \
    /bin/bash <<'CHROOT'

export DEBIAN_FRONTEND=noninteractive

apt-get update


apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    qt6-base-dev \
    qt6-declarative-dev \
    qt6-qpa-plugins \
    qml6-module-qtquick \
    qml6-module-qtquick-window \
    qml6-module-qtquick-controls \
    qml6-module-qtquick-templates \
    qml6-module-qtquick-layouts \
    qml6-module-qtqml \
    qml6-module-qtqml-workerscript \
    libqt6gui6 \
    libqt6qml6 \
    libqt6quick6 \
    libqt6network6 \
    libgl1-mesa-dri \
    libegl1 \
    libinput10 \
    network-manager \
    bluez \
    rfkill \
    brightnessctl \
    wireplumber \
    modemmanager \
    ca-certificates \
    fonts-dejavu-core


if [ "$?" -ne 0 ]; then
    echo "ARM package installation failed"
    exit 40
fi


echo
echo "ARM architecture:"
uname -m

dpkg --print-architecture

CHROOT


if [ "$?" -ne 0 ]; then
    die "ARM Qt installation failed"
fi


# ============================================================
# Build LumaShell natively for ARM64 through qemu-user
# ============================================================

say "7/10 Building ARM64 LumaShell"


sudo chroot \
    "$MNT" \
    /usr/bin/qemu-aarch64-static \
    /bin/bash <<'CHROOT'

cd /opt/lumamobile-src/shell


rm -rf build-arm


cmake \
    -S . \
    -B build-arm \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DLUMASHELL_QML_DIR=/usr/share/lumashell/qml


if [ "$?" -ne 0 ]; then
    exit 50
fi


cmake \
    --build build-arm \
    -j2


if [ "$?" -ne 0 ]; then
    exit 51
fi


BIN="$(
    find build-arm \
        -type f \
        -name lumashell \
        -executable \
        -print \
        | head -1
)"


if [ -z "$BIN" ]; then

    echo "Could not find ARM LumaShell binary"

    exit 52
fi


install \
    -m 0755 \
    "$BIN" \
    /usr/bin/lumashell


rm -rf \
    /usr/share/lumashell/qml


mkdir -p \
    /usr/share/lumashell


cp -a \
    /opt/lumamobile-src/shell/qml \
    /usr/share/lumashell/


echo
echo "LumaShell binary:"
file /usr/bin/lumashell

CHROOT


if [ "$?" -ne 0 ]; then
    die "ARM LumaShell build failed"
fi


# ============================================================
# Build Framework + LMS
# ============================================================

say "8/10 Building ARM64 Framework + LMS"


sudo chroot \
    "$MNT" \
    /usr/bin/qemu-aarch64-static \
    /bin/bash <<'CHROOT'


# ------------------------------------------------------------
# Luma Framework
# ------------------------------------------------------------

cd /opt/lumamobile-src/framework


cc \
    -O2 \
    -std=gnu11 \
    -Iinclude \
    src/lumad.c \
    -o /usr/sbin/lumad


if [ "$?" -ne 0 ]; then
    exit 60
fi


cc \
    -O2 \
    -std=gnu11 \
    -Iinclude \
    src/lumactl.c \
    -o /usr/bin/lumactl


if [ "$?" -ne 0 ]; then
    exit 61
fi


# ------------------------------------------------------------
# LMS
# ------------------------------------------------------------

cd /opt/lumamobile-src/services/lms


cc \
    -O2 \
    -std=gnu11 \
    -Iinclude \
    src/lmsd.c \
    -o /usr/sbin/lmsd


if [ "$?" -ne 0 ]; then
    exit 62
fi


cc \
    -O2 \
    -std=gnu11 \
    -Iinclude \
    src/lmsctl.c \
    -o /usr/bin/lmsctl


if [ "$?" -ne 0 ]; then
    exit 63
fi


chmod 0755 \
    /usr/sbin/lumad \
    /usr/bin/lumactl \
    /usr/sbin/lmsd \
    /usr/bin/lmsctl


echo
echo "ARM services:"
file \
    /usr/sbin/lumad \
    /usr/sbin/lmsd

CHROOT


if [ "$?" -ne 0 ]; then
    die "Framework/LMS ARM build failed"
fi


# ============================================================
# Raspberry Pi display + touch
# ============================================================

say "9/10 Configuring XPT2046 display"


CONFIG="$MNT/boot/firmware/config.txt"

CMDLINE="$MNT/boot/firmware/cmdline.txt"


sudo cp \
    "$CONFIG" \
    "$CONFIG.before-lumamobile"


sudo tee \
    -a \
    "$CONFIG" \
    >/dev/null <<EOF


# ============================================================
# LumaMobile — Raspberry Pi 4 / XPT2046
# ============================================================

dtparam=spi=on

# ------------------------------------------------------------
# 3.5" SPI LCD
# ------------------------------------------------------------

dtoverlay=fbtft,spi0-0,${LUMA_LCD_DRIVER},bgr,reset_pin=${LUMA_LCD_RESET},dc_pin=${LUMA_LCD_DC},led_pin=${LUMA_LCD_LED},rotate=${LUMA_LCD_ROTATE},speed=${LUMA_LCD_SPEED}


# ------------------------------------------------------------
# XPT2046 touch controller
#
# Linux uses the ADS7846-compatible driver.
# ------------------------------------------------------------

dtoverlay=ads7846,cs=${LUMA_TOUCH_CS},penirq=${LUMA_TOUCH_IRQ},penirq_pull=2,speed=${LUMA_TOUCH_SPEED},swapxy=1,xohms=${LUMA_TOUCH_XOHMS},pmax=255


# Don't waste boot time on the firmware splash.
disable_splash=1

EOF


# ============================================================
# Quiet boot
# ============================================================

if [ -f "$CMDLINE" ]; then

    CMD="$(
        cat "$CMDLINE"
    )"


    # Keep root= and all important Pi parameters while removing
    # visible tty1 console output.

    CMD="$(
        echo "$CMD" \
            | sed \
                -E \
                's/(^| )console=tty1( |$)/ /g;
                 s/(^| )quiet( |$)/ /g;
                 s/(^| )loglevel=[^ ]+( |$)/ /g;
                 s/[[:space:]]+/ /g'
    )"


    echo \
        "$CMD quiet loglevel=3 vt.global_cursor_default=0" \
        | sudo tee "$CMDLINE" >/dev/null

fi


# ============================================================
# Luma filesystem
# ============================================================

sudo mkdir -p \
    "$MNT/data/home/luma/Documents" \
    "$MNT/data/home/luma/Downloads" \
    "$MNT/data/home/luma/Pictures" \
    "$MNT/data/home/luma/Music" \
    "$MNT/data/appdata" \
    "$MNT/data/packages" \
    "$MNT/var/lib/lms" \
    "$MNT/run/luma" \
    "$MNT/run/lms"


sudo chmod -R \
    0777 \
    "$MNT/data/home/luma"


# ============================================================
# LumaShell ARM launcher
# ============================================================

sudo mkdir -p \
    "$MNT/usr/lib/luma"


sudo tee \
    "$MNT/usr/lib/luma/launch-shell-rpi4.sh" \
    >/dev/null <<EOF
#!/bin/sh


echo "[LumaARM] Raspberry Pi 4 target"


export HOME=/data/home/luma

export XDG_RUNTIME_DIR=/run/luma-shell


mkdir -p "\$XDG_RUNTIME_DIR"

chmod 0700 "\$XDG_RUNTIME_DIR"


# ============================================================
# Find SPI framebuffer
# ============================================================

FRAMEBUFFER=""


for SYSFB in /sys/class/graphics/fb*
do

    [ -e "\$SYSFB" ] || continue


    NAME="\$(
        cat "\$SYSFB/name" 2>/dev/null
    )"


    DEV="/dev/\$(
        basename "\$SYSFB"
    )"


    echo \
        "[LumaARM] framebuffer \$DEV = \$NAME"


    case "\$NAME" in

        *ili9486*|*ILI9486*|*fbtft*|*fb_ili*)

            FRAMEBUFFER="\$DEV"

            break

            ;;

    esac

done


if [ -z "\$FRAMEBUFFER" ]; then

    if [ -e /dev/fb1 ]; then

        FRAMEBUFFER=/dev/fb1

    elif [ -e /dev/fb0 ]; then

        FRAMEBUFFER=/dev/fb0

    fi

fi


if [ -z "\$FRAMEBUFFER" ]; then

    echo \
        "[LumaARM] ERROR: framebuffer not found"

    exit 100

fi


echo \
    "[LumaARM] using \$FRAMEBUFFER"


# ============================================================
# Find XPT2046
# ============================================================

TOUCH=""


for EVENT in /dev/input/event*
do

    [ -e "\$EVENT" ] || continue


    E="\$(
        basename "\$EVENT"
    )"


    NAME="\$(
        cat \
            "/sys/class/input/\$E/device/name" \
            2>/dev/null
    )"


    echo \
        "[LumaARM] input \$EVENT = \$NAME"


    case "\$NAME" in

        *ADS7846*|*ads7846*|*XPT2046*|*xpt2046*)

            TOUCH="\$EVENT"

            break

            ;;

    esac

done


# ============================================================
# Qt
# ============================================================

export QT_QPA_PLATFORM="linuxfb:fb=\$FRAMEBUFFER"

export QT_QUICK_BACKEND=software

export QT_QPA_FB_HIDECURSOR=1


# Current UI is designed for a taller display.
# This is TEMPORARY until LumaShell gets its proper
# responsive 320x480 layout.

export QT_SCALE_FACTOR="${LUMA_UI_SCALE}"

export QT_SCALE_FACTOR_ROUNDING_POLICY=PassThrough


if [ -n "\$TOUCH" ]; then

    echo \
        "[LumaARM] touchscreen = \$TOUCH"

    export QT_QPA_GENERIC_PLUGINS=evdevtouch

    export QT_QPA_EVDEV_TOUCHSCREEN_PARAMETERS="\$TOUCH"

else

    echo \
        "[LumaARM] WARNING: touchscreen not detected"

fi


echo "[LumaARM] starting LumaShell"


exec \
    /usr/bin/lumashell

EOF


sudo chmod +x \
    "$MNT/usr/lib/luma/launch-shell-rpi4.sh"


# ============================================================
# systemd: Framework
# ============================================================

sudo tee \
    "$MNT/etc/systemd/system/lumad.service" \
    >/dev/null <<'EOF'

[Unit]
Description=Luma Framework
After=local-fs.target

[Service]
Type=simple

RuntimeDirectory=luma

ExecStart=/usr/sbin/lumad

Restart=always

RestartSec=1

[Install]
WantedBy=multi-user.target

EOF


# ============================================================
# systemd: LMS
# ============================================================

sudo tee \
    "$MNT/etc/systemd/system/lmsd.service" \
    >/dev/null <<'EOF'

[Unit]
Description=LumaMobile Services
After=lumad.service
Requires=lumad.service

[Service]
Type=simple

RuntimeDirectory=lms

ExecStart=/usr/sbin/lmsd

Restart=always

RestartSec=1

[Install]
WantedBy=multi-user.target

EOF


# ============================================================
# systemd: shell
# ============================================================

sudo tee \
    "$MNT/etc/systemd/system/lumashell.service" \
    >/dev/null <<'EOF'

[Unit]
Description=LumaMobile Shell

After=systemd-udev-settle.service
After=lumad.service
After=lmsd.service
After=NetworkManager.service

Requires=lumad.service
Requires=lmsd.service

Wants=systemd-udev-settle.service


[Service]

Type=simple

User=root

WorkingDirectory=/data/home/luma

ExecStartPre=/bin/sleep 1

ExecStart=/usr/lib/luma/launch-shell-rpi4.sh

Restart=always

RestartSec=2


[Install]
WantedBy=multi-user.target

EOF


# ============================================================
# Enable services directly
# ============================================================

sudo mkdir -p \
    "$MNT/etc/systemd/system/multi-user.target.wants"


sudo ln -sf \
    ../lumad.service \
    "$MNT/etc/systemd/system/multi-user.target.wants/lumad.service"


sudo ln -sf \
    ../lmsd.service \
    "$MNT/etc/systemd/system/multi-user.target.wants/lmsd.service"


sudo ln -sf \
    ../lumashell.service \
    "$MNT/etc/systemd/system/multi-user.target.wants/lumashell.service"


# Don't put a login prompt over LumaShell.

sudo ln -sf \
    /dev/null \
    "$MNT/etc/systemd/system/getty@tty1.service"


# ============================================================
# Identity
# ============================================================

echo "lumamobile" \
    | sudo tee \
        "$MNT/etc/hostname" \
        >/dev/null


sudo sed \
    -i \
    's/^127\.0\.1\.1.*/127.0.1.1\tlumamobile/' \
    "$MNT/etc/hosts"


# ============================================================
# Clean build environment
# ============================================================

sudo rm -f \
    "$MNT/usr/sbin/policy-rc.d"


sudo chroot \
    "$MNT" \
    /usr/bin/qemu-aarch64-static \
    /bin/bash <<'CHROOT'

apt-get clean

rm -rf \
    /var/lib/apt/lists/*


echo
echo "Installed Luma binaries:"

file \
    /usr/bin/lumashell \
    /usr/sbin/lumad \
    /usr/sbin/lmsd

CHROOT


# ============================================================
# Finalize
# ============================================================

say "10/10 Finalizing ARM image"


sync


cleanup


trap - EXIT INT TERM


mv \
    "$WORK_IMG" \
    "$FINAL_IMG"


echo
echo "============================================================"
echo "          LumaMobile ARM64 IMAGE READY"
echo "============================================================"
echo
echo "Output:"
echo
echo "  $FINAL_IMG"
echo
ls -lh "$FINAL_IMG"
echo
echo "Target:"
echo
echo "  Raspberry Pi 4B"
echo "  ARM64"
echo "  ILI9486 3.5-inch SPI LCD"
echo "  XPT2046 touch"
echo
echo "Boot:"
echo
echo "  Raspberry Pi firmware"
echo "      ↓"
echo "  ARM64 Raspberry Pi Linux"
echo "      ↓"
echo "  lumad"
echo "      ↓"
echo "  lmsd"
echo "      ↓"
echo "  LumaShell"
echo
echo "DONE ✓"

