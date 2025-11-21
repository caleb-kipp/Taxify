# On‑Demand Boda Platform

> Starter repo: pilot-ready stack for an on‑demand motorbike‑taxi (boda) platform.

## Overview
This repository contains starter files for launching an MVP pilot of an on‑demand motorbike/taxi & services platform targeted for pilot in Baringo, Kenya. The project is structured for local dev with Docker Compose and for production deployment via Kubernetes and CI/CD using GitHub Actions.

### Included starter files
- `README.md` (this file)
- `docker-compose.dev.yml` — local dev stack (Postgres + PostGIS, Redis, MinIO, mock services)
- `openapi.yaml` — OpenAPI v3 (basic endpoints)
- `schema.sql` — Postgres schema with PostGIS types
- `.github/workflows/ci.yml` — CI pipeline
- `.github/workflows/cd-dev.yml` — CD to dev (example)
- `.github/workflows/cd-prod.yml` — Production deploy (manual)

## Quick start (local dev)
Prerequisites: Docker, Docker Compose (v2+), Git, Node.js (for frontend dev servers), optionally `psql`.

1. Clone the repo:
```bash
git clone <your-repo-url>
cd on-demand-boda-platform