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

Open `arkts/` in DevEco Studio, select a HarmonyOS NEXT device or emulator, and run the `entry` module. Update the API host for a physical device; on a device, `localhost` means the device itself.

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
