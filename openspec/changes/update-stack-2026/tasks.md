## 1. Infrastructure Updates

- [x] 1.1 Update Traefik to v3.x with v2 compatibility mode
- [x] 1.2 Add Traefik v3 specific configuration options
- [x] 1.3 Update Traefik dashboard labels for v3
- [ ] 1.4 Test Traefik routing after upgrade

## 2. Service Image Updates

- [x] 2.1 Update Sonarr to v4 (current `latest`)
- [x] 2.2 Update Radarr to v5 (current `latest`)
- [x] 2.3 Switch Readarr from LinuxServer to hotio image
- [x] 2.4 Update Lidarr to current version
- [x] 2.5 Update Prowlarr to current version
- [x] 2.6 Update Bazarr to current version
- [x] 2.7 Update qBittorrent to current version
- [x] 2.8 Update Homarr to current version
- [x] 2.9 Update FlareSolverr to current version
- [x] 2.10 Update Recyclarr to current version
- [x] 2.11 Update Deleterr to current version
- [x] 2.12 Update Portainer to current version
- [x] 2.13 Update Plex to current version
- [x] 2.14 Update Calibre-web to current version
- [x] 2.15 Update Organizr to current version

## 3. Tooling Changes

- [x] 3.1 Remove Watchtower service
- [x] 3.2 Add What's Up Docker (WUD) service
- [x] 3.3 Configure WUD watcher and triggers
- [x] 3.4 Add WUD labels to all services
- [x] 3.5 Migrate Overseerr to Seerr
- [ ] 3.6 Test Seerr functionality

## 4. Dark Theme Implementation

- [x] 4.1 Add theme.park DOCKER_MODS to Sonarr
- [x] 4.2 Add theme.park DOCKER_MODS to Radarr
- [x] 4.3 Add theme.park DOCKER_MODS to Lidarr
- [x] 4.4 Add theme.park DOCKER_MODS to Readarr (hotio format)
- [x] 4.5 Add theme.park DOCKER_MODS to Prowlarr
- [x] 4.6 Add theme.park DOCKER_MODS to Bazarr
- [x] 4.7 Add theme.park DOCKER_MODS to qBittorrent
- [x] 4.8 Add theme.park DOCKER_MODS to Seerr
- [x] 4.9 Add TP_THEME environment variable (default: nord)
- [ ] 4.10 Test all dark themes render correctly

## 5. Configuration Updates

- [x] 5.1 Add PUID/PGID to all service environment variables
- [x] 5.2 Add TP_THEME to .env.example
- [x] 5.3 Update __defaults__/docker-compose.yml
- [x] 5.4 Update __defaults__/.env if needed

## 6. Documentation Updates

- [x] 6.1 Update docs/services.md with new versions
- [x] 6.2 Update docs/maintenance.md for WUD usage
- [x] 6.3 Create migration guide in docs/migration.md
- [x] 6.4 Add theming section to docs/configuration.md
- [x] 6.5 Update README.md with 2026 stack info
- [x] 6.6 Update VERSION file

## 7. Validation

- [ ] 7.1 Test fresh installation with --defaults flag
- [ ] 7.2 Test migration from backup
- [ ] 7.3 Verify all services start correctly
- [ ] 7.4 Verify Traefik routes all services
- [ ] 7.5 Verify WUD detects and reports updates
- [ ] 7.6 Verify Seerr handles requests correctly
- [ ] 7.7 Verify dark themes applied to all services
- [ ] 7.8 Run `openspec validate update-stack-2026 --strict --no-interactive`

## Dependencies

- Tasks in Section 1 must complete before Section 5
- Tasks in Section 3.1-3.4 can run in parallel
- Task 3.5 depends on 2.1-2.6 being complete
- Section 4 can run in parallel with Section 2
- Section 7 requires all previous sections complete

## Parallelizable Work

- All tasks in Section 2 can run in parallel
- All tasks in Section 4 can run in parallel
- Tasks 5.1-5.4 can run in parallel
- Tasks 6.1-6.5 can run in parallel
