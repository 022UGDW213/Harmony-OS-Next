# Harmony OS Next — Full-Stack Ark Platform

A clean foundation for HarmonyOS NEXT development with a native ArkTS client, React control plane, typed Fastify API, PostgreSQL data layer, and an isolated native boundary.

## Architecture

```text
ArkTS / ArkUI device client ─┐
                              ├─ Fastify API ─ PostgreSQL
React + TypeScript web client ┘       │
                               native C/C++ boundary
```

| Layer | Location | Responsibility |
|---|---|---|
| Native client | `arkts/entry/` | HarmonyOS NEXT ArkUI experience |
| Web client | `src/` | Browser control plane and API playground |
| API | `server/index.ts` | Health, capabilities, chat, and service boundary |
| Database | `db/` | PostgreSQL schema and event persistence |
| Delivery | `Dockerfile`, `docker-compose.yml` | Reproducible local services |

## Quickstart

```bash
npm install
npm run dev
```

Or run the complete local stack:

```bash
docker compose up --build
```

- Web control plane: <http://localhost:5173>
- API health: <http://localhost:3003/health>
- API capabilities: <http://localhost:3003/api/capabilities>

## ArkTS development

`arkts/` is a complete DevEco Studio project: `AppScope/`, the `entry`
module (hvigor build files, `oh-package`, resources, `EntryAbility`), and
the Zen breathing app under `ets/features/zen/`.

- Open `arkts/` in DevEco Studio, select a HarmonyOS NEXT device or
  emulator, and run the `entry` module.
- Headless build (DevEco command-line tools on PATH):
  `hvigorw assembleHap` from `arkts/`.
- Update the API host for a physical device; on a device, `localhost`
  means the device itself.

## VM — DevEco in a virtual machine

`vm/` builds a reproducible DevEco development VM (Ubuntu 24.04 + JDK 17 +
Node + DevEco CLI tools) and boots it with KVM when available, TCG
otherwise — so Windows, macOS, or Linux hosts all work the same way.

```bash
cd vm && ./build-deveco-vm.sh && ./launch-deveco-vm.sh
# ssh -p 2222 dev@localhost
```

It also includes an experimental script that boots the HarmonyOS phone
emulator image directly under QEMU. See [vm/README.md](vm/README.md).

### Zen — breathing companion app

The `entry` module ships a complete minimalist app built with Zen architecture
(clean layered structure: theme → state → services → UI):

| Layer | Location | Responsibility |
|---|---|---|
| Theme | `ets/features/zen/theme/` | Design tokens — colors, spacing, type |
| State | `ets/features/zen/state/` | `ZenSession` (`@Observed`) — phase, timer, progress |
| Services | `ets/features/zen/services/` | `BreathEngine` — pure inhale 4s → hold 4s → exhale 6s state machine |
| UI | `ets/features/zen/ui/` | `BreathCircle` (animated) and `ZenControls` (timer, stats, length picker) |
| Page | `ets/pages/Index.ets` | Composes the Zen home screen |

Features: animated breathing circle, 1/3/5-minute sessions, breath counter,
elapsed/session stats, progress bar, calm dark theme with sage accents.

## Commands

```bash
npm run dev          # web and API in development
npm run dev:web      # Vite only
npm run dev:api      # Fastify only
npm run build        # production web build
npm run typecheck    # TypeScript validation
npm test             # test runner
```

## Archive

The previous repository state is preserved at the Git branch `archive/pre-full-stack-rewrite-20260910`.

## Security

Copy `.env.example` to `.env` for local configuration. Never commit API keys, JWT secrets, database passwords, or device credentials.

MIT License
