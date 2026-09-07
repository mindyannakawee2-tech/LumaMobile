#!/usr/bin/env bash

cd "$HOME/LumaMobile"

exec qemu-system-x86_64 \
    -enable-kvm \
    -machine q35 \
    -cpu host \
    -smp 2 \
    -m 1024 \
    -kernel kernel/linux-6.18.49/arch/x86/boot/bzImage \
    -initrd output/lumamobile-initramfs.cpio.gz \
    -append "console=ttyS0 rdinit=/init loglevel=4" \
    -nographic
