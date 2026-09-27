# vm/ — DevEco virtual machines

Everything needed to develop for HarmonyOS NEXT inside a virtual machine,
so one computer can host the whole toolchain regardless of host OS
(Windows, macOS, or Linux).

## 0. Host prerequisites (probed 2026-09-27)

The scripts check these themselves; none of them are installed by the repo.

| Tool | Used by | Present on the verification workstation |
|---|---|---|
| `qemu-system-x86_64` | `launch-deveco-vm.sh`, `launch-emulator.sh` | yes — `/usr/bin/qemu-system-x86_64` |
| `qemu-img` | `build-deveco-vm.sh`, `launch-emulator.sh` | yes — `/usr/bin/qemu-img` |
| `/dev/kvm` | KVM acceleration (both launchers fall back to TCG) | yes — `/dev/kvm` exists |
| `cloud-localds` or `genisoimage` | `build-deveco-vm.sh` seed-ISO step (`build-deveco-vm.sh:74-80`; the script exits 1 without one) | **no** — neither is installed |
| DevEco command-line tools (`hvigorw`, `hdc`, `ohpm`) | `hvigorw assembleHap` inside the VM | **no** — none on `PATH` |
| HarmonyOS system image | `launch-emulator.sh` (`$SDK`, default `$HOME/workspace/deveco/2600821/command-line-tools/sdk`) | **no** — that path does not exist |

The Ubuntu 24.04 cloud image `build-deveco-vm.sh` downloads was reachable on
2026-09-27 —
`curl -sI https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img`
→ `HTTP/1.1 200 OK`, `Content-Length: 625612288`,
`Last-Modified: Sat, 26 Sep 2026 13:13:58 GMT`. Those header values are
point-in-time: Ubuntu rebuilds the `current` image periodically, so they change
without this repository changing. Neither VM was booted during that check: the
scripts were read and their host prerequisites probed, not executed end to end.

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
>
> This is the author's observation of 2026-09-17. It was **not** re-run on
> 2026-09-27: the HarmonyOS system image is not present on the verification
> workstation (§0), so the emulator cannot be started there at all.

## Files

| File | Purpose |
|---|---|
| `build-deveco-vm.sh` | Build the DevEco dev-VM disk + cloud-init seed ISO |
| `launch-deveco-vm.sh` | Boot the dev VM (KVM if present, else TCG) |
| `launch-emulator.sh` | Boot the HarmonyOS phone image directly (experimental) |
