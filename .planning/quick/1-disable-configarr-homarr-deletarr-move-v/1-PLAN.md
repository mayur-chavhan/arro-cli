# Quick Task 001 — PLAN

## Description
disable configarr, homarr, deletarr. move volumes on mount to config data folder with specific folders. fix homepage error.

## Tasks

### Task 1: Disable configarr, homarr, deleterr
files: docker-compose.yml
action: Add `profiles: [disabled]` to configarr, homarr, and deleterr services so they are excluded from default `docker compose up`.
verify: Each of the 3 services has a `profiles:` key with `[disabled]`.
done: false

### Task 2: Move named volumes to bind mounts under ${CONFIG_ROOT}
files: docker-compose.yml
action: |
  Replace the following named volumes with bind-mount equivalents pointing to `${CONFIG_ROOT}/<service>/`:
  - traefik_data → ${CONFIG_ROOT}/traefik/letsencrypt (used in traefik service)
  - wud_data     → ${CONFIG_ROOT}/wud/store (used in wud service)
  - dockhand_data → ${CONFIG_ROOT}/dockhand/data (used in dockhand service)
  - jellystat_db  → ${CONFIG_ROOT}/jellystat-db/data (used in jellystat-db service)
  - jellystat_data → ${CONFIG_ROOT}/jellystat/backup-data (used in jellystat service)
  Remove the named volume declarations (traefik_data, wud_data, dockhand_data, jellystat_db, jellystat_data) from the `volumes:` section at the top. Keep homepage_data or remove if unused.
verify: Named volumes `traefik_data`, `wud_data`, `dockhand_data`, `jellystat_db`, `jellystat_data` no longer appear in the top-level `volumes:` section, and each service uses the corresponding bind-mount path.
done: false

### Task 3: Fix homepage HOMEPAGE_ALLOWED_HOSTS error
files: docker-compose.yml
action: |
  The error says: "Host validation failed for 192.168.1.11:3004". The `HOMEPAGE_ALLOWED_HOSTS` env var currently only includes `${DOMAIN:-localhost}` which doesn't cover direct IP access.
  Update the homepage service environment to include the local IP and port:
  `HOMEPAGE_ALLOWED_HOSTS: "${DOMAIN:-localhost}:3004,192.168.1.11:3004"`
  Also mirror the change in __defaults__/docker-compose.yml.
verify: HOMEPAGE_ALLOWED_HOSTS env var includes both domain and `192.168.1.11:3004`.
done: false
