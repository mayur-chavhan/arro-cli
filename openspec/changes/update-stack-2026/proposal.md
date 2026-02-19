# Change: Update ArrGo Stack to 2026 Standards

## Why

ArrGo has not been updated in 2+ years. Major version upgrades are available for core services (Traefik v3, Sonarr v4, Radarr v5), critical tools are deprecated (Watchtower archived Dec 2025), and new consolidated projects have emerged (Seerr merger). This update brings the stack to current standards with security fixes, new features, dark theme support, and sustainable maintenance paths.

## What Changes

### **BREAKING** - Core Infrastructure
- **Traefik v2.10 → v3.x**: Major version upgrade with configuration migration required
- **Watchtower → What's Up Docker (WUD)**: Replaces deprecated auto-update tool
- **Overseerr → Seerr**: Migrate to unified Jellyseerr/Overseerr codebase

### Dark Theme Support (theme.park)
- **Sonarr**: Dark theme via Docker mod
- **Radarr**: Dark theme via Docker mod
- **Lidarr**: Dark theme via Docker mod
- **Readarr**: Dark theme via Docker mod
- **Prowlarr**: Dark theme via Docker mod
- **Bazarr**: Dark theme via Docker mod
- **qBittorrent**: Dark theme via Docker mod
- **Seerr**: Dark theme via Docker mod
- **Homarr**: Built-in dark mode support

### Service Updates
- **Sonarr**: v3 → v4 (current `latest` tag)
- **Radarr**: v4 → v5 (current `latest` tag)
- **Readarr**: Switch from archived LinuxServer image to `hotio/readarr`
- **Lidarr**: Update to current version
- **Prowlarr**: Update to current version
- **Bazarr**: Update to current version
- **qBittorrent**: Update to current version
- **Homarr**: Update to current version
- **FlareSolverr**: Update to current version
- **Recyclarr**: Update to current version
- **Deleterr**: Update to current version
- **Portainer**: Update to current version
- **Plex**: Update to current version
- **Calibre-web**: Update to current version
- **Organizr**: Update to current version

### Configuration Updates
- Add PUID/PGID environment variables to all services
- Add DOCKER_MODS for theme.park theming
- Add TP_THEME environment variable for theme selection
- Update Traefik labels for v3 compatibility
- Add WUD labels for update notifications
- Update documentation to reflect changes

## Impact

- **Affected specs**: docker-stack, traefik, services, tooling, theming
- **Affected code**: 
  - `docker-compose.yml`
  - `__defaults__/docker-compose.yml`
  - `.env.example`
  - `docs/services.md`
  - `docs/maintenance.md`
- **Migration required**: 
  - Traefik v2 → v3 requires config backup and migration
  - Overseerr → Seerr requires data migration
  - Watchtower removal, WUD setup
  - Theme changes take effect on container restart
- **Downtime**: Services will need restart during migration
