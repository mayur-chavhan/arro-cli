# Change: Migrate to Jellyfin Stack with Enhanced Services

## Why

ArrGo currently uses Plex as the media server and lacks several modern *arr ecosystem tools that have emerged. This change modernizes the stack by:

1. **Replacing Plex with Jellyfin** - Fully open-source alternative with no licensing restrictions, no tracking, and native hardware transcoding support
2. **Replacing Portainer with Dockhand** - Modern Docker management with OIDC/SSO included free, vulnerability scanning, and zero telemetry
3. **Adding missing media automation tools** - Huntarr (missing content hunter), Recommendarr (AI recommendations), Boxarr (box office tracking), Profilarr (quality profiles), Configarr (configuration management)
4. **Adding Jackett** - Legacy indexer proxy for broader tracker support alongside Prowlarr
5. **Adding Jellystat** - Statistics and monitoring dashboard for Jellyfin
6. **Adding Cloudflare Tunnel support** - Secure external access without port forwarding
7. **Adding Docker Socket Proxy** - Enhanced security by restricting Docker API access
8. **Removing Lidarr and Readarr** - Simplifying stack focus on movies and TV

## What Changes

### **BREAKING** - Media Server
- **REMOVE** Plex Media Server
- **ADD** Jellyfin Media Server

### **BREAKING** - Container Management
- **REMOVE** Portainer
- **ADD** Dockhand

### **BREAKING** - Removed Services
- **REMOVE** Lidarr (music management)
- **REMOVE** Readarr (book management)

### New Services Added
- **Jellyfin** - Open-source media server (replaces Plex)
- **Jellystat** - Jellyfin statistics and monitoring dashboard
- **Dockhand** - Docker management platform (replaces Portainer)
- **Huntarr** - Automated missing content hunter for *arr apps
- **Recommendarr** - AI-powered media recommendations
- **Boxarr** - Box office tracking with Radarr integration
- **Profilarr** - Quality profile management for Sonarr/Radarr
- **Configarr** - Configuration management for *arr apps
- **Jackett** - Indexer proxy for torrent trackers
- **Cloudflare Tunnel** (optional) - Secure external access via cloudflared
- **Docker Socket Proxy** - Security layer for Docker socket access

### Configuration Changes
- **ADD** `TUNNEL_TOKEN` environment variable for optional Cloudflare Tunnel
- **KEEP** AUDIO and BOOKS paths for Jellyfin media libraries
- **REMOVE** `PLEX_CLAIM` environment variable
- **ADD** `JELLYFIN_PUBLISHED_SERVER_URL` for reverse proxy configuration

## Impact

### Affected Specs
- `specs/media-server/spec.md` - New spec for Jellyfin-centric media serving
- `specs/tooling/spec.md` - New tools: Dockhand, Socket Proxy, Cloudflare Tunnel
- `specs/services/spec.md` - New services: Huntarr, Recommendarr, Boxarr, Profilarr, Configarr, Jackett, Jellystat
- `specs/security/spec.md` - New spec for security enhancements

### Affected Code
- `docker-compose.yml` - Major restructuring
- `__defaults__/docker-compose.yml` - Same changes
- `.env.example` - Add TUNNEL_TOKEN, remove PLEX_CLAIM
- `__defaults__/.env` - Same changes
- `docs/services.md` - Update service documentation
- `docs/maintenance.md` - Update for Dockhand
- `docs/migration.md` - Add Plex→Jellyfin migration section
- `docs/configuration.md` - Update for new services
- `README.md` - Update stack overview
- `VERSION` - Bump to 3.0.0

### Migration Considerations
- **Plex → Jellyfin**: Users must recreate libraries in Jellyfin; no direct migration path
- **Portainer → Dockhand**: Stack configurations must be manually recreated
- **Lidarr/Readarr removal**: Audio and book paths preserved for Jellyfin but no management tools
- **Volume compatibility**: All existing config volumes remain unchanged

### Data Preservation
- **Preserved**: All existing config volumes (sonarr, radarr, prowlarr, etc.)
- **Preserved**: AUDIO and BOOKS media paths for Jellyfin
- **Removed**: Plex config volume (no longer needed)
- **Removed**: Lidarr and Readarr config volumes
