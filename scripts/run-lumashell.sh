#!/usr/bin/env bash

ROOT="$HOME/LumaMobile"

cd "$ROOT"

echo
echo "========================================"
echo "       Booting LumaMobile GUI"
echo "========================================"
echo
echo "LumaShell will be the system shell."
echo


qemu-system-x86_64 \
    -enable-kvm \
    -machine q35 \
    -cpu host \
    -smp 4 \
    -m 2048 \
    -kernel \
        kernel/linux-6.18.49/arch/x86/boot/bzImage \
    -initrd \
        output/lumamobile-initramfs.cpio.gz \
    -append \
        "console=ttyS0 rdinit=/init loglevel=4 video=Virtual-1:720x1280@60" \
    -device virtio-vga \
    -device virtio-tablet-pci \
    -display gtk,gl=off \
    -serial stdio \
    -monitor none \
    -no-reboot
