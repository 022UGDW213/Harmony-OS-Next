# Harmony OS Next full-stack Ark development

This repository now has three compatible development surfaces:

1. **ArkTS/ArkUI client** in `arkts/entry/` for native HarmonyOS NEXT development.
2. **React/Vite control plane** at the repository root for browser-based iteration.
3. **Node reasoning API and native kernel bridge** in `server/`, providing AI reasoning, threat intelligence, and kernel status.

## API contract

| Method | Endpoint | Purpose |
|---|---|---|
| `GET` | `/health` | Service status and provider availability |
| `GET` | `/capabilities` | Feature flags for reasoning and threat analysis |
| `GET` | `/api/kernel/status` | Native kernel bridge status |
| `POST` | `/chat` | AI reasoning request with optional context |
| `POST` | `/analyze` | Strategic security analysis |

## Local development

```bash
npm install
npm run dev
npm run reasoning-api
```

The browser control plane runs through Vite. The reasoning service defaults to port `3003`; configure provider keys through a local `.env` based on `.env.example`. Never commit provider keys.

## ArkTS development

Open the `arkts/` directory with DevEco Studio and configure the target device or emulator. The starter entry module contains an ArkUI status surface and a web-control page. Update the API base URL for a physical device or emulator according to the network topology; `localhost` refers to the device itself when running natively.

## Architecture boundary

ArkUI and React are client surfaces. The Node service is the API boundary. The native kernel remains an isolated, separately built component accessed through the kernel bridge. This keeps privileged bare-metal code separate from user-facing application code.
