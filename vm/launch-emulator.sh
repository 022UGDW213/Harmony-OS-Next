#!/usr/bin/env bash
# ── launch-emulator.sh ─────────────────────────────────────────────────
# Boots the HarmonyOS phone emulator image directly under QEMU with
# software rendering (TCG). This bypasses the DevEco emulator launcher,
# which requires genuine KVM.
#
# STATUS (verified 2026-09-17): the HarmonyOS 7 kernel loads and executes
# under TCG and detects all four VirtIO disks, then panics in
# express_hotplug_init / express_gpu_init — Huawei's kernel expects
# proprietary emulator hardware. The emulator is NOT yet usable this way;
# this script is kept for experimentation.
#
# Usage:
#   SDK=/path/to/deveco/.../sdk ./launch-emulator.sh
#   SDK defaults to the DevEco 5.1 SDK layout used during development.
set -euo pipefail

SDK="${SDK:-$HOME/workspace/deveco/2600821/command-line-tools/sdk}"
IMG_DIR="$SDK/system-image/HarmonyOS-7.0.0/phone_all_x86"
WORK="${WORK:-$HOME/.harmony-vm/emulator}"

for f in bzImage ramdisk.img system.img vendor.img userdata.img sys_prod.img; do
  [ -f "$IMG_DIR/$f" ] || { echo "✗ missing $IMG_DIR/$f" >&2; exit 1; }
done

# Work on qcow2 overlays so the pristine SDK images are never modified.
mkdir -p "$WORK"
for part in system vendor sys_prod; do
  [ -f "$WORK/$part.qcow2" ] || \
    qemu-img create -f qcow2 -F raw -b "$IMG_DIR/$part.img" "$WORK/$part.qcow2"
done
# userdata gets a writable 6G disk (emulator config: hw.dataPartitionSize=6144)
if [ ! -f "$WORK/userdata.qcow2" ]; then
  qemu-img create -f qcow2 "$WORK/userdata.qcow2" 6G
  echo "→ fresh 6G userdata created"
fi

exec qemu-system-x86_64 \
  -accel tcg,thread=multi \
  -m 3072 -smp 4 \
  -machine pc,accel=tcg \
  -kernel "$IMG_DIR/bzImage" \
  -initrd "$IMG_DIR/ramdisk.img" \
  -append "console=ttyS0,115200 root=/dev/ram0 rw" \
  -drive "file=$WORK/system.qcow2,format=qcow2,if=virtio" \
  -drive "file=$WORK/vendor.qcow2,format=qcow2,if=virtio" \
  -drive "file=$WORK/userdata.qcow2,format=qcow2,if=virtio" \
  -drive "file=$WORK/sys_prod.qcow2,format=qcow2,if=virtio" \
  -device virtio-serial-pci \
  -nographic
