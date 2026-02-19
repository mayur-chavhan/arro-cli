## 1. Media Server Migration

- [x] 1.1 Remove Plex service from docker-compose.yml
- [x] 1.2 Add Jellyfin service with proper configuration
- [x] 1.3 Configure Jellyfin environment variables
- [x] 1.4 Map all media paths (MOVIES, SERIES, AUDIO, BOOKS)
- [x] 1.5 Add theme.park support for Jellyfin
- [x] 1.6 Add WUD labels to Jellyfin
- [x] 1.7 Add Traefik labels for Jellyfin routing

## 2. Container Management Migration

- [x] 2.1 Remove Portainer service from docker-compose.yml
- [x] 2.2 Add Dockhand service
- [x] 2.3 Configure Dockhand to use Docker Socket Proxy
- [x] 2.4 Add WUD labels to Dockhand
- [x] 2.5 Add Traefik labels for Dockhand routing

## 3. Security Infrastructure

- [x] 3.1 Add Docker Socket Proxy service
- [x] 3.2 Configure socket proxy environment variables
- [x] 3.3 Update Traefik to use socket proxy
- [x] 3.4 Update WUD to use socket proxy
- [x] 3.5 Update Dockhand to use socket proxy
- [x] 3.6 Add Cloudflare Tunnel service (commented out)
- [x] 3.7 Add TUNNEL_TOKEN to .env.example

## 4. Remove Deprecated Services

- [x] 4.1 Remove Lidarr service from docker-compose.yml
- [x] 4.2 Remove Readarr service from docker-compose.yml
- [x] 4.3 Remove Calibre service from docker-compose.yml
- [x] 4.4 Update .env.example to remove related variables

## 5. Add New Services

### 5.1 Jellystat
- [x] 5.1.1 Add PostgreSQL service for Jellystat
- [x] 5.1.2 Add Jellystat service
- [x] 5.1.3 Configure Jellystat environment variables
- [x] 5.1.4 Add WUD labels to Jellystat
- [x] 5.1.5 Add Traefik labels for Jellystat routing

### 5.2 Huntarr
- [x] 5.2.1 Add Huntarr service
- [x] 5.2.2 Configure Huntarr environment variables
- [x] 5.2.3 Add WUD labels to Huntarr
- [x] 5.2.4 Add Traefik labels for Huntarr routing

### 5.3 Recommendarr
- [x] 5.3.1 Add Recommendarr service
- [x] 5.3.2 Configure Recommendarr environment variables
- [x] 5.3.3 Add WUD labels to Recommendarr
- [x] 5.3.4 Add Traefik labels for Recommendarr routing

### 5.4 Boxarr
- [x] 5.4.1 Add Boxarr service
- [x] 5.4.2 Configure Boxarr environment variables
- [x] 5.4.3 Add WUD labels to Boxarr
- [x] 5.4.4 Add Traefik labels for Boxarr routing

### 5.5 Profilarr
- [x] 5.5.1 Add Profilarr service
- [x] 5.5.2 Configure Profilarr environment variables
- [x] 5.5.3 Add WUD labels to Profilarr
- [x] 5.5.4 Add Traefik labels for Profilarr routing

### 5.6 Configarr
- [x] 5.6.1 Add Configarr service
- [x] 5.6.2 Configure Configarr volumes
- [x] 5.6.3 Add WUD labels to Configarr

### 5.7 Jackett
- [x] 5.7.1 Add Jackett service
- [x] 5.7.2 Configure Jackett environment variables
- [x] 5.7.3 Add theme.park support for Jackett
- [x] 5.7.4 Add WUD labels to Jackett
- [x] 5.7.5 Add Traefik labels for Jackett routing

## 6. Update Existing Services

- [x] 6.1 Update Seerr to connect to Jellyfin instead of Plex
- [x] 6.2 Update Homarr configuration for new services
- [x] 6.3 Update Bazarr to use Jellyfin paths
- [x] 6.4 Update Deleterr to use Jellyfin paths

## 7. Configuration Files

- [x] 7.1 Update .env.example with new variables
- [x] 7.2 Remove PLEX_CLAIM from .env.example
- [x] 7.3 Add TUNNEL_TOKEN to .env.example
- [x] 7.4 Update __defaults__/docker-compose.yml
- [x] 7.5 Update __defaults__/.env

## 8. Documentation

- [x] 8.1 Update docs/services.md with new services
- [x] 8.2 Update docs/maintenance.md for Dockhand
- [x] 8.3 Update docs/migration.md with Plex→Jellyfin section
- [x] 8.4 Update docs/configuration.md with new services
- [x] 8.5 Create docs/jellyfin-setup.md for initial configuration
- [x] 8.6 Update README.md with new stack overview
- [x] 8.7 Update VERSION to 3.0.0

## 9. Validation

- [ ] 9.1 Test fresh installation with --defaults flag
- [ ] 9.2 Verify Jellyfin starts and serves media
- [ ] 9.3 Verify Jellystat connects to Jellyfin
- [ ] 9.4 Verify Dockhand manages containers
- [ ] 9.5 Verify Docker Socket Proxy restricts access
- [ ] 9.6 Verify all new services start correctly
- [ ] 9.7 Verify Traefik routes all services
- [ ] 9.8 Verify WUD detects all services
- [ ] 9.9 Run `openspec validate jellyfin-stack-2026 --strict --no-interactive`

## Dependencies

- Tasks in Section 3 must complete before Section 2 (socket proxy needed for Dockhand)
- Tasks in Section 4 can run in parallel with Section 1
- Tasks in Section 5 can run in parallel
- Section 7 requires Sections 1-6 complete
- Section 8 requires Section 7 complete
- Section 9 requires all previous sections complete

## Parallelizable Work

- All tasks in Section 5 can run in parallel
- Tasks 8.1-8.5 can run in parallel
- Most tasks in Section 7 can run in parallel
