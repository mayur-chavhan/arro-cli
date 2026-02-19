# Project Context

## Purpose

ArrGo is a comprehensive Docker-based media server stack that provides automated media management, streaming, and organization. It consolidates the popular *arr ecosystem applications (Sonarr, Radarr, Lidarr, Readarr, Prowlarr) with download clients, media servers, and management tools into a single deployable solution.

## Tech Stack

- **Container Orchestration**: Docker Compose
- **Reverse Proxy**: Traefik v3.x
- **Media Server**: Plex
- **Media Management**: Sonarr, Radarr, Lidarr, Readarr, Prowlarr, Bazarr
- **Download Client**: qBittorrent
- **Request Management**: Seerr (unified Overseerr/Jellyseerr)
- **Dashboard**: Homarr
- **Container Management**: Portainer
- **Update Management**: What's Up Docker (WUD)
- **Theming**: theme.park

## Project Conventions

### Code Style

- Docker Compose files use YAML with 2-space indentation
- Environment variables use SCREAMING_SNAKE_CASE
- Container names match service names
- Networks are explicitly named `media_network`

### Architecture Patterns

- All services use common environment template (x-common)
- Services are accessed via Traefik reverse proxy with subdomain routing
- Configuration data stored in `${CONFIG_ROOT}` directory
- Media stored in `${STORAGE_ROOT}` directory
- Docker socket mounted read-only where needed

### Testing Strategy

- Fresh installation tested via `./install.sh --defaults`
- Migration tested from backup restore
- Service health verified via `./arrgo.sh check`
- All services must start and respond to HTTP requests

### Git Workflow

- Main branch contains stable releases
- Feature work in separate branches
- Commits follow conventional commit format
- Breaking changes documented in CHANGELOG

## Domain Context

### *arr Ecosystem

- **Sonarr**: TV series management, integrates with indexers and download clients
- **Radarr**: Movie management, similar workflow to Sonarr
- **Lidarr**: Music management for audio libraries
- **Readarr**: Book and audiobook management
- **Prowlarr**: Indexer aggregator, replaces individual indexer configurations
- **Bazarr**: Subtitle management, integrates with Sonarr/Radarr

### Media Flow

1. User requests media via Seerr or directly in *arr apps
2. *arr app searches indexers via Prowlarr
3. Download sent to qBittorrent
4. Completed download imported to library
5. Plex indexes and streams media

## Important Constraints

- **No Breaking Path Changes**: Volume mappings must remain compatible for existing users
- **Preserve User Data**: Configurations and media files must survive updates
- **Minimal Downtime**: Updates should require only container restarts
- **Default Credentials**: Must be documented and users warned to change them

## External Dependencies

- **Docker**: Required runtime platform
- **Docker Compose**: Container orchestration
- **LinuxServer.io**: Primary image source for *arr apps
- **hotio**: Alternative image source (Readarr)
- **theme.park**: Dark theme provider via Docker mods
- **Plex.tv**: Claim token for server setup
