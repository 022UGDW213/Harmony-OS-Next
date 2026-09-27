# Harmony OS Next — Full-Stack Ark Platform

A foundation for HarmonyOS NEXT development: a native ArkTS/ArkUI client, a
React control plane, a typed Fastify API, and a PostgreSQL schema.

The claims below were measured on 2026-09-27 — see
[Verified state](#verified-state-2026-09-27) for the command behind each
value. What does not exist yet is listed in
[Not implemented yet](#not-implemented-yet) instead of being described as if
it worked.

## Architecture

```text
ArkTS / ArkUI device client ─┐
                              ├─ Fastify API ─ PostgreSQL schema
React + TypeScript web client ┘
```

| Layer | Location | Responsibility |
|---|---|---|
| Native client | `arkts/entry/` | HarmonyOS NEXT ArkUI experience — 7 `.ets` files, the Zen breathing app |
| Web client | `src/`, `index.html` | Browser control plane and API playground |
| API | `server/index.ts` | Three routes: `GET /health`, `GET /api/capabilities`, `POST /api/chat` (echoes the message; no model behind it) |
| Database | `db/001_init.sql` | PostgreSQL schema — `workspaces`, `events`, `events_workspace_created_idx`. `docker-compose.yml` mounts `./db` at the postgres image's `/docker-entrypoint-initdb.d`, so the schema would be applied on the container's first boot; that never ran here (no compose CLI — see Delivery) and `server/` does not read or write the database yet |
| Delivery | `Dockerfile`, `docker-compose.yml` | Local services. The compose file parses as valid YAML. Docker 29.1.3 is installed and its daemon answers, but there is no `compose` subcommand — `docker compose version` → `docker: unknown command: docker compose` — and no standalone `docker-compose` on `PATH`, so the stack was never brought up here |

## Quickstart

Verified with Node v22.23.2 / npm 12.0.2 (the `Dockerfile` pins `node:22-bookworm-slim`). `package.json` declares no `engines` field, so the repository itself enforces no minimum.

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

Both ports were served and answered with HTTP 200 during verification
(Vite 6.4.3 on 5173, Fastify 5.12.5 on 3003).

## ArkTS development

`arkts/` is a DevEco Studio project layout: `AppScope/`, the `entry`
module (hvigor build files, `oh-package`, resources, `EntryAbility`), and
the Zen breathing app under `ets/features/zen/`.

- Open `arkts/` in DevEco Studio, select a HarmonyOS NEXT device or
  emulator, and run the `entry` module.
- Headless build (DevEco command-line tools on PATH):
  `hvigorw assembleHap` from `arkts/`.
- Update the API host for a physical device; on a device, `localhost`
  means the device itself.

**Not verified by building:** no HarmonyOS device, emulator, DevEco Studio
or `hvigorw` exists on the verification workstation (`command -v hvigorw
hdc ohpm` → all missing; `/opt/deveco` and `~/.harmony-vm` absent), so the
ArkTS module was never compiled or run. Its files were read and their
contents confirmed, but no build was performed. The SDK version strings are
unverifiable for the same reason: `arkts/build-profile.json5` and
`arkts/entry/build-profile.json5` declare `compatibleSdkVersion` /
`compileSdkVersion` `26.0.0`, while `arkts/AppScope/app.json5` declares
`minAPIVersion` / `targetAPIVersion` `12`. Both are reported as written, not
as correct.

## VM — DevEco in a virtual machine

`vm/` builds a reproducible DevEco development VM (Ubuntu 24.04 + JDK 17 +
Node + DevEco CLI tools) and boots it with KVM when available, TCG
otherwise — so Windows, macOS, or Linux hosts all work the same way.

```bash
cd vm && ./build-deveco-vm.sh && ./launch-deveco-vm.sh
# ssh -p 2222 dev@localhost
```

Prerequisites are checked by the scripts at runtime, not installed by them:
`build-deveco-vm.sh` needs `cloud-localds` or `genisoimage` to build the
cloud-init seed ISO and exits 1 without either; `launch-deveco-vm.sh` needs
`qemu-system-x86_64` and `qemu-img`. On the verification workstation
(2026-09-26) QEMU and `qemu-img` were present and `/dev/kvm` existed, but
neither ISO tool was installed, so the build step could not be completed
there — see [vm/README.md](vm/README.md) for the full prerequisite table.

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

Features: animated breathing circle, 1/3/5-minute sessions (`LENGTHS = [60, 180, 300]`),
breath counter, elapsed/session stats, progress bar, calm dark theme with
sage accents.

## Commands

```bash
npm run dev          # web and API in development
npm run dev:web      # Vite only
npm run dev:api      # Fastify only
npm run build        # production web build (vite build → dist/)
npm run typecheck    # TypeScript validation (tsc --noEmit)
npm start            # run the API (tsx server/index.ts)
npm test             # vitest — no test file exists, so it reports code 1
```

`npm test` is wired to vitest 3.2.7, but the repository contains no
`*.test.*` / `*.spec.*` file (`git ls-files | grep -E '\.(test|spec)\.'` →
nothing), so the runner reports `No test files found, exiting with code 1`
(`node node_modules/vitest/vitest.mjs run` → exit 1). It is listed because
the script exists, not because there is a passing suite behind it. On this
working copy `npm run test` itself exits 127 with `vitest: not found` before
the runner starts — see the filesystem note under
[Verified state](#verified-state-2026-09-27).

## Archive

The previous repository state is preserved at the Git branch
`archive/pre-full-stack-rewrite-20260910` — HEAD
`62e1177e40f4d7ad0085a74685cb20401157e030` (`feat: add full-stack ArkTS
development foundation`), 220 tracked files. Re-confirmed 2026-09-27 with
`git ls-remote --heads origin` and `git ls-tree -r --name-only
62e1177e40f4d7ad0085a74685cb20401157e030 | wc -l`.

## Verified state (2026-09-27)

Measured on the verification workstation; nothing here is copied from
another document.

| Fact | Measured value | Command |
|---|---|---|
| Node / npm | v22.23.2 / 12.0.2 | `node --version`, `npm --version` |
| Tracked files | 39 | `git ls-files \| wc -l` |
| ArkTS project files | 21 files, of which 7 `.ets` | `find arkts -type f \| wc -l` |
| TypeScript check | exit 0 (TypeScript 5.9.3) | `node node_modules/typescript/lib/tsc.js --noEmit` |
| Web build | exit 0 — 28 modules → `dist/` (227.05 kB JS / 70.65 kB gzip, 2.53 kB CSS) | `node node_modules/vite/bin/vite.js build` |
| `GET /health` | 200 `{"status":"online","version":"1.0.0","database":"development","kernel":"isolated"}` | `curl -s http://127.0.0.1:3003/health` |
| `GET /api/capabilities` | 200 `{"clients":["arkts","react"],"services":["health","chat","capabilities"],"nativeBoundary":true}` | `curl -s http://127.0.0.1:3003/api/capabilities` |
| `POST /api/chat` | 200 `{"reply":"Harmony control plane received: verify route","mode":"development"}` | `curl -s -X POST http://127.0.0.1:3003/api/chat -H 'content-type: application/json' -d '{"message":"verify route"}'` |
| `POST /api/chat` with no message | 200 `{"error":"message is required"}` | same route, body `{}` |
| Unknown route / wrong method | 404 / 404 | `curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:3003/unknown`; the same against `GET /api/chat` |
| Web control plane | 200 `text/html`, 625 bytes | `curl -s -o /dev/null -w '%{http_code} %{size_download}' http://127.0.0.1:5173/` |
| `node_modules/` tracked in Git | 0 files — correctly ignored | `git ls-files node_modules \| wc -l` |
| JSON/JSON5 project files | 14 parse cleanly | `git ls-files \| grep -E '\.json5?$'`, then `JSON.parse` on each |
| PostgreSQL schema | 2 tables + 1 index | `db/001_init.sql` |
| Archive branch | HEAD `62e1177e…`, 220 tracked files | `git ls-remote --heads origin`; `git ls-tree -r --name-only 62e1177e… \| wc -l` |
| Docker | 29.1.3, daemon answers; no `compose` subcommand, no standalone `docker-compose` | `docker --version`, `docker info`, `docker compose version` |

> Filesystem note: the verification working copy sits on an exFAT volume
> (`df -T .` → `/dev/sda3  exfat`), where npm cannot create the
> `node_modules/.bin` shims that `npm run <script>` depends on — that
> directory does not exist. Every npm script therefore fails there with
> `<tool>: not found` and exit 127; measured for `npm run test` (`vitest:
> not found`), `npm run typecheck` (`tsc: not found`) and `npm run build`
> (`vite: not found`). The tools were invoked directly from `node_modules/`
> as listed above. This is a property of that filesystem, not of the
> repository.

## Not implemented yet

Listed so the architecture is not read as describing more than exists:

- **Native C/C++ boundary** — `GET /api/capabilities` returns
  `nativeBoundary: true` and `/health` reports `kernel: "isolated"`, but the
  repository contains no native source. `find . -name '*.c' -o -name '*.cpp'
  -o -name '*.h' -o -name '*.hpp' -o -name '*.rs'` returns nothing. The flag
  marks an intended boundary, not a built one.
- **Event persistence** — `db/001_init.sql` defines `workspaces` and
  `events`, but nothing in `server/` or `src/` reads or writes the database:
  `@fastify/postgres` is registered only when `DATABASE_URL` is set, and no
  query is ever issued.
- **Chat** — `POST /api/chat` echoes the message it receives
  (`"Harmony control plane received: …"`) and reports
  `mode: "development"`; there is no model, queue or storage behind it.
- **Test suite** — vitest is installed and configured, and no test file
  exists, so `npm test` exits 1.
- **Authentication** — `@fastify/jwt` is a declared dependency and
  `.env.example` documents `JWT_SECRET`, but no JWT plugin is registered and
  no route is authenticated.

## Security

Copy `.env.example` to `.env` for local configuration. Never commit API keys, JWT secrets, database passwords, or device credentials.

MIT License
