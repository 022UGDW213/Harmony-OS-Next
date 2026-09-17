#!/usr/bin/env bash
# ── build-deveco-vm.sh ─────────────────────────────────────────────────
# Builds a reusable DevEco development VM disk:
#   Ubuntu 24.04 cloud image + cloud-init (JDK 17, Node, guest agent, git)
#   + optional DevEco command-line tools attached as a data disk.
#
# Usage:
#   ./build-deveco-vm.sh
#   DEVECO_CLI_DIR=/path/to/command-line-tools ./build-deveco-vm.sh
#
# Output:  $VM_DIR/deveco-vm.qcow2  (OS disk)
#          $VM_DIR/seed.iso         (cloud-init seed)
#          $VM_DIR/deveco-tools.img (data disk, only if DEVECO_CLI_DIR set)
set -euo pipefail

VM_DIR="${VM_DIR:-$HOME/.harmony-vm}"
CLOUD_IMG_URL="${CLOUD_IMG_URL:-https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img}"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_ed25519.pub}"

mkdir -p "$VM_DIR"
cd "$VM_DIR"

BASE_IMG="$VM_DIR/noble-base.img"
if [ ! -f "$BASE_IMG" ]; then
  echo "→ downloading Ubuntu 24.04 cloud image…"
  curl -L -o "$BASE_IMG" "$CLOUD_IMG_URL"
fi

if [ ! -f "$SSH_KEY" ]; then
  echo "✗ no SSH public key at $SSH_KEY (checked id_ed25519.pub)" >&2
  echo "  generate one: ssh-keygen -t ed25519" >&2
  exit 1
fi
PUBKEY="$(cat "$SSH_KEY")"

# ── cloud-init user-data ───────────────────────────────────────────────
cat > user-data <<EOF
#cloud-config
hostname: deveco-vm
manage_etc_hosts: true
users:
  - name: dev
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - $PUBKEY
packages:
  - openjdk-17-jdk-headless
  - nodejs
  - npm
  - qemu-guest-agent
  - git
  - unzip
  - curl
mounts:
  - [ vdb, /opt/deveco, auto, "defaults,nofail", "0", "0" ]
runcmd:
  - [ systemctl, enable, --now, qemu-guest-agent ]
  - |
    if [ -x /opt/deveco/bin/hvigorw ]; then
      echo 'export PATH=/opt/deveco/bin:$PATH' >> /home/dev/.bashrc
      echo 'export DEVECO_CLI_HOME=/opt/deveco' >> /home/dev/.bashrc
    fi
  - chown -R dev:dev /home/dev
final_message: "deveco-vm ready — ssh dev@<vm-ip>"
EOF

cat > meta-data <<EOF
instance-id: deveco-vm-01
local-hostname: deveco-vm
EOF

# ── seed ISO ───────────────────────────────────────────────────────────
if command -v cloud-localds >/dev/null 2>&1; then
  cloud-localds seed.iso user-data meta-data
elif command -v genisoimage >/dev/null 2>&1; then
  genisoimage -output seed.iso -volid cidata -joliet -rock user-data meta-data
else
  echo "✗ need cloud-localds or genisoimage to build the seed ISO" >&2
  exit 1
fi

# ── OS disk (qcow2 overlay on the cloud base) ──────────────────────────
qemu-img create -f qcow2 -F raw -b "$BASE_IMG" deveco-vm.qcow2 20G

# ── optional DevEco tools data disk ────────────────────────────────────
if [ -n "${DEVECO_CLI_DIR:-}" ] && [ -d "$DEVECO_CLI_DIR" ]; then
  echo "→ packing DevEco command-line tools from $DEVECO_CLI_DIR…"
  SIZE_MB=$(du -sm "$DEVECO_CLI_DIR" | cut -f1)
  qemu-img create -f raw deveco-tools.img "$(( SIZE_MB + 512 ))M"
  mkfs.ext4 -q -F deveco-tools.img
  MNT="$(mktemp -d)"
  sudo mount -o loop deveco-tools.img "$MNT"
  sudo cp -a "$DEVECO_CLI_DIR/." "$MNT/"
  sudo umount "$MNT" && rmdir "$MNT"
  echo "→ tools disk ready (mounts at /opt/deveco in the VM)"
else
  echo "→ skipping tools disk (set DEVECO_CLI_DIR to include DevEco CLI tools)"
fi

echo "✓ VM built in $VM_DIR"
echo "  boot it with: ./launch-deveco-vm.sh"
echo "  then: ssh -p 2222 dev@localhost"
