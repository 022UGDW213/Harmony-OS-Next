# vm/ — DevEco virtual machines

Everything needed to develop for HarmonyOS NEXT inside a virtual machine,
so one computer can host the whole toolchain regardless of host OS
(Windows, macOS, or Linux).

## 1. DevEco development VM (recommended)

A reproducible Ubuntu 24.04 VM with JDK 17, Node, and the QEMU guest agent,
plus your DevEco command-line tools mounted at `/opt/deveco`.

```bash
cd vm
./build-deveco-vm.sh
# with DevEco CLI tools baked in as a data disk:
DEVECO_CLI_DIR=$HOME/workspace/deveco/command-line-tools ./build-deveco-vm.sh

./launch-deveco-vm.sh            # headless (serial console)
./launch-deveco-vm.sh --display  # graphical window

ssh -p 2222 dev@localhost
```

Inside the VM, the `arkts/` project in this repo opens directly in
DevEco Studio (or builds headless with `hvigorw assembleHap`).

- KVM is used automatically when `/dev/kvm` exists; otherwise QEMU falls
  back to software emulation (TCG) — slower, but it works.
- Disks live in `$HOME/.harmony-vm` (override with `VM_DIR`).
- The base cloud image is downloaded once and reused as a backing file;
  each build creates a thin qcow2 overlay, so rebuilds are cheap.

## 2. HarmonyOS phone emulator under QEMU (experimental)

`launch-emulator.sh` boots the HarmonyOS 7 phone system image directly
under QEMU with software rendering, bypassing the DevEco emulator launcher
(which needs genuine KVM).

```bash
cd vm
SDK=$HOME/workspace/deveco/2600821/command-line-tools/sdk ./launch-emulator.sh
```

> **Status (2026-09-17):** the kernel loads and runs under TCG and detects
> all four VirtIO disks (system / vendor / userdata / sys_prod), then
> panics in `express_hotplug_init` / `express_gpu_init` — Huawei's kernel
> expects proprietary emulator hardware. Not usable yet; kept here for
> experimentation.

## Files

| File | Purpose |
|---|---|
| `build-deveco-vm.sh` | Build the DevEco dev-VM disk + cloud-init seed ISO |
| `launch-deveco-vm.sh` | Boot the dev VM (KVM if present, else TCG) |
| `launch-emulator.sh` | Boot the HarmonyOS phone image directly (experimental) |
