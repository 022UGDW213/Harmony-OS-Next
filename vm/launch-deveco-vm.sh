#!/usr/bin/env bash
# ── launch-deveco-vm.sh ────────────────────────────────────────────────
# Boots the DevEco development VM built by build-deveco-vm.sh.
# Uses KVM when available, falls back to software emulation (TCG).
#
#   ./launch-deveco-vm.sh            # headless, serial on stdio
#   ./launch-deveco-vm.sh --display  # with a graphical window
set -euo pipefail

VM_DIR="${VM_DIR:-$HOME/.harmony-vm}"
IMG="$VM_DIR/deveco-vm.qcow2"
SEED="$VM_DIR/seed.iso"
TOOLS="$VM_DIR/deveco-tools.img"

[ -f "$IMG" ]  || { echo "✗ $IMG missing — run ./build-deveco-vm.sh first" >&2; exit 1; }
[ -f "$SEED" ] || { echo "✗ $SEED missing — run ./build-deveco-vm.sh first" >&2; exit 1; }

if [ -e /dev/kvm ]; then
  ACCEL="-accel kvm"
  echo "→ KVM acceleration available"
else
  ACCEL="-accel tcg,thread=multi"
  echo "→ no KVM — using software emulation (slower, still works)"
fi

DISPLAY_ARGS=(-nographic)
if [ "${1:-}" = "--display" ]; then
  DISPLAY_ARGS=(-vga virtio -display gtk)
fi

ARGS=(
  qemu-system-x86_64 $ACCEL
  -m 8G -smp 4
  -drive "file=$IMG,format=qcow2,if=virtio"
  -drive "file=$SEED,format=raw,if=virtio,readonly=on"
  -netdev user,id=net0,hostfwd=tcp::2222-:22
  -device virtio-net-pci,netdev=net0
  "${DISPLAY_ARGS[@]}"
)
if [ -f "$TOOLS" ]; then
  ARGS+=(-drive "file=$TOOLS,format=raw,if=virtio")
fi

echo "→ SSH will be on localhost:2222 (user: dev)"
exec "${ARGS[@]}"
