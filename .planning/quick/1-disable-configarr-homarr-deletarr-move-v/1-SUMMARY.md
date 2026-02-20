# Quick Task 001 — SUMMARY

## What Was Done

Three maintenance tasks fully applied across both compose files and all shell scripts:

### Task 1: Disable configarr, homarr, deleterr
Added `profiles: [disabled]` to homarr, deleterr, and configarr in both `docker-compose.yml` and `__defaults__/docker-compose.yml`. Services are excluded from default `docker compose up`.

### Task 2: Move named volumes to bind mounts
Replaced all five named volumes with bind mounts under `${CONFIG_ROOT}/`:
- `traefik_data:/letsencrypt` → `${CONFIG_ROOT}/traefik/letsencrypt:/letsencrypt`
- `wud_data:/store` → `${CONFIG_ROOT}/wud/store:/store`
- `dockhand_data:/app/data` → `${CONFIG_ROOT}/dockhand/data:/app/data`
- `jellystat_db:/var/lib/postgresql/data` → `${CONFIG_ROOT}/jellystat-db/data:/var/lib/postgresql/data`
- `jellystat_data:/app/backend/backup-data` → `${CONFIG_ROOT}/jellystat/backup-data:/app/backend/backup-data`

Named volume declarations removed from top-level `volumes:` section in both compose files.

### Task 3: Fix homepage HOMEPAGE_ALLOWED_HOSTS
Updated to `"${DOMAIN:-localhost}:3004,192.168.1.11:3004"` in both compose files.

## Shell Scripts Updated

- `init.sh` — `directories[]` updated: homarr/deleterr/configarr removed, new bind-mount paths added
- `generate-configs.sh` — `generate_service_dirs()` updated; Homarr and Deleterr removed from homepage `services.yaml`; `generate_deleterr_config` call removed from main block
- `reset.sh` — `confirm_purge_volumes` prompt updated to reflect bind mounts instead of named volumes
- `install.sh` — Homarr and Calibre removed from `print_login_info()`

## Commits

- `415777f` — chore: disable homarr, deleterr, configarr via profiles (Task 1, docker-compose.yml only)
- Second commit — chore: move named volumes to bind mounts, fix HOMEPAGE_ALLOWED_HOSTS, update scripts
