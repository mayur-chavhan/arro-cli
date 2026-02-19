## Context

ArrGo is a 2-year-old Docker-based media server stack. The project has remained static while the *arr ecosystem and related tools have evolved significantly. Key drivers for this update:

- **Security**: Outdated container images may have vulnerabilities
- **Sustainability**: Watchtower archived, Readarr LinuxServer repo archived
- **Features**: Major versions offer significant improvements (Sonarr v4, Radarr v5)
- **Consolidation**: Seerr merger reduces maintenance burden
- **User Experience**: Dark themes reduce eye strain and modernize UI

### Stakeholders
- End users running the stack
- Contributors maintaining the project

## Goals / Non-Goals

### Goals
- Update all container images to current stable versions
- Migrate from deprecated tools to actively maintained alternatives
- Provide smooth migration path for existing users
- Add dark theme support for all compatible services
- Update documentation to reflect changes
- Maintain backward compatibility where possible

### Non-Goals
- Adding new services not currently in the stack
- Changing the directory structure or volume mappings
- Modifying the installation script behavior
- Changing default credentials

## Decisions

### 1. Traefik v2 → v3 Migration

**Decision**: Upgrade to Traefik v3.3 with v2 compatibility mode enabled initially.

**Rationale**: 
- v2 will eventually lose support
- v3 offers performance improvements and new features
- Compatibility mode allows gradual migration

**Implementation**:
```yaml
# Add to traefik command section
core:
  defaultRuleSyntax: v2
```

**Alternatives considered**:
- Stay on v2: Rejected due to eventual deprecation
- Use nginx-proxy: Rejected as would require complete rewrite

### 2. Watchtower → What's Up Docker (WUD)

**Decision**: Replace Watchtower with WUD for container update management.

**Rationale**:
- Watchtower archived Dec 17, 2025
- WUD is actively maintained with similar functionality
- WUD offers better control and notification options
- Web UI for monitoring updates

**Implementation**:
```yaml
wud:
  image: fmartinou/whats-up-docker
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock:ro
  environment:
    - WUD_WATCHER_LOCAL_CRON=0 0 4 * * *
    - WUD_TRIGGER_MOCK_EXAMPLE_MOCK=true
```

**Alternatives considered**:
- Diun: Rejected as notification-only (no update trigger)
- Keep Watchtower: Rejected as archived/unmaintained
- Manual updates only: Rejected as user unfriendly

### 3. Overseerr → Seerr Migration

**Decision**: Migrate to Seerr (unified Overseerr/Jellyseerr project).

**Rationale**:
- Official merger of both projects
- Single codebase = faster updates
- Adds Jellyfin/Emby support for future flexibility
- All Overseerr features preserved

**Implementation**:
- Change image from `sctx/overseerr:latest` to `sctx/seerr:latest`
- Configuration is compatible, but backup recommended
- Port remains 5055

**Alternatives considered**:
- Keep Overseerr: Possible but project may diverge from Seerr
- Switch to Jellyseerr: Less relevant for Plex-focused stack

### 4. Readarr Image Switch

**Decision**: Switch from `linuxserver/readarr:develop` to `hotio/readarr:latest`.

**Rationale**:
- LinuxServer Readarr repo archived July 2025
- hotio maintains active Readarr builds
- Configuration should be compatible

**Alternatives considered**:
- Keep archived image: Rejected due to no future updates
- Remove Readarr: Rejected as users rely on the service

### 5. *arr Service Image Versions

**Decision**: Keep using `:latest` tags for all *arr services.

**Rationale**:
- LinuxServer images follow semantic versioning
- `latest` now points to major new versions (Sonarr v4, Radarr v5)
- Watchtower/WUD will handle updates
- Breaking changes are handled by app migration on first run

### 6. Dark Theme Implementation (theme.park)

**Decision**: Use theme.park Docker mods for consistent dark theming across all services.

**Rationale**:
- theme.park is actively maintained with 10k+ Docker pulls
- Supports all *arr apps, qBittorrent, Overseerr/Seerr, Homarr
- Multiple theme options: dark, nord, dracula, aquamarine, etc.
- Simple Docker mod integration for LinuxServer images
- Non-invasive: can be disabled by removing environment variable

**Implementation**:
```yaml
# For LinuxServer images
environment:
  - DOCKER_MODS=ghcr.io/themepark-dev/theme.park:sonarr
  - TP_THEME=nord  # Options: dark, nord, dracula, aquamarine, plex, maroon, space-gray

# For hotio images (Readarr)
environment:
  - DOCKER_MODS=ghcr.io/themepark-dev/theme.park:readarr
  - TP_THEME=nord
```

**Supported Services**:
| Service | Theme Support |
|---------|--------------|
| Sonarr | ✅ Docker mod |
| Radarr | ✅ Docker mod |
| Lidarr | ✅ Docker mod |
| Readarr | ✅ Docker mod |
| Prowlarr | ✅ Docker mod |
| Bazarr | ✅ Docker mod |
| qBittorrent | ✅ Docker mod |
| Seerr | ✅ Docker mod |
| Homarr | ✅ Built-in settings |

**Theme Options**:
- `dark` - Basic dark theme
- `nord` - Nord color scheme (default for ArrGo)
- `dracula` - Dracula color scheme
- `aquamarine` - Blue-green accents
- `plex` - Plex-style dark theme
- `maroon` - Dark red accents
- `space-gray` - Gray tones

**Alternatives considered**:
- Custom CSS injection: More complex, harder to maintain
- Individual app settings: Inconsistent across apps
- VueTorrent for qBittorrent: Different UI, may confuse users

## Risks / Trade-offs

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Traefik v3 breaks routing | Medium | High | Enable v2 compatibility mode; test before deploying |
| Seerr migration loses data | Low | Medium | Backup Overseerr config before migration |
| hotio/readarr incompatible | Low | Medium | Test in isolated environment first |
| Major *arr version issues | Low | Medium | Backup configs; apps have migration paths |
| Theme.park CDN unavailable | Low | Low | Themes cached locally after first load |

## Migration Plan

### Pre-Migration (User Actions)
1. Backup all configurations: `./arrgo.sh backup`
2. Note current service ports and credentials
3. Ensure sufficient disk space for updates

### Migration Steps
1. Stop all services: `./arrgo.sh stop`
2. Pull new docker-compose.yml
3. Pull new images: `docker-compose pull`
4. Start services: `./arrgo.sh start`
5. Verify Traefik routing works
6. Verify Seerr migration completed
7. Configure WUD notifications
8. Verify dark themes applied (refresh browser)

### Rollback Plan
1. Stop services
2. Restore backup: `./arrgo.sh restore <backup-file>`
3. Use previous docker-compose.yml from git
4. Start services

## Open Questions

1. ~~Should we add WUD notification integrations (Discord, Telegram, etc.)?~~ → Document in post-install
2. Should we provide a migration script or just documentation?
3. Should Homepage be added as an alternative dashboard option to Homarr?
4. Should TP_THEME be configurable via .env for easy customization?
