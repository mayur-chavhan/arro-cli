## Context

ArrGo is transitioning from a Plex-centric stack to a Jellyfin-centric stack with enhanced media automation capabilities. This reflects the growing preference for fully open-source solutions in the self-hosting community and adds several modern tools that have emerged in the *arr ecosystem.

### Stakeholders
- Existing users migrating from Plex to Jellyfin
- New users seeking a modern, fully open-source media stack
- Contributors maintaining the project

## Goals / Non-Goals

### Goals
- Provide a fully open-source media server solution with Jellyfin
- Add modern automation tools (Huntarr, Recommendarr, Boxarr, Profilarr, Configarr)
- Improve security with Docker Socket Proxy
- Enable secure external access via optional Cloudflare Tunnel
- Simplify stack by removing niche services (Lidarr, Readarr)
- Maintain backward compatibility for existing volume mappings

### Non-Goals
- Providing automatic Plex → Jellyfin migration (not possible)
- Supporting both Plex and Jellyfin simultaneously
- Keeping Portainer alongside Dockhand
- Adding VPN/proxy services beyond FlareSolverr

## Decisions

### 1. Plex → Jellyfin Migration

**Decision**: Replace Plex entirely with Jellyfin.

**Rationale**:
- Jellyfin is fully open-source with no licensing or feature restrictions
- No account required, no tracking, no premium tiers
- Native hardware transcoding support
- Better privacy-focused alternative
- Growing community and active development

**Implementation**:
```yaml
jellyfin:
  image: lscr.io/linuxserver/jellyfin:latest
  ports:
    - 8096:8096
  environment:
    <<: *commonenv
    JELLYFIN_PUBLISHED_SERVER_URL: http://jellyfin.${DOMAIN:-localhost}
  volumes:
    - ${CONFIG_ROOT}/jellyfin:/config
    - ${STORAGE_ROOT}/MOVIES:${MOVIES_PATH}
    - ${STORAGE_ROOT}/SERIES:${SERIES_PATH}
    - ${STORAGE_ROOT}/AUDIO:${MUSIC_PATH}
    - ${STORAGE_ROOT}/BOOKS:${BOOKS_PATH}
```

**Alternatives considered**:
- Keep both Plex and Jellyfin: Rejected to avoid complexity and resource usage
- Emby: Rejected due to licensing model similar to Plex

### 2. Portainer → Dockhand Migration

**Decision**: Replace Portainer with Dockhand for container management.

**Rationale**:
- Modern UI with better UX
- OIDC/SSO included in free tier (Portainer charges for this)
- Built-in vulnerability scanning (Grype, Trivy)
- Zero telemetry
- MFA/TOTP support built-in
- Safe-pull protection for updates

**Implementation**:
```yaml
dockhand:
  image: ghcr.io/dockhand/dockhand:latest
  environment:
    <<: *commonenv
    DOCKER_HOST: tcp://docker-socket-proxy:2375
  volumes:
    - ${CONFIG_ROOT}/dockhand:/app/data
```

**Alternatives considered**:
- Keep Portainer: Rejected as Dockhand offers more features for free
- Run both: Rejected to avoid redundancy

### 3. Docker Socket Proxy for Security

**Decision**: Add Docker Socket Proxy to restrict API access for services that need Docker socket.

**Rationale**:
- Reduces security risk by limiting Docker API access
- Fine-grained control over which operations are allowed
- Services like Dockhand, WUD, Traefik can use restricted socket
- Defense-in-depth security approach

**Implementation**:
```yaml
docker-socket-proxy:
  image: tecnativa/docker-socket-proxy:latest
  environment:
    - CONTAINERS=1
    - IMAGES=1
    - NETWORKS=1
    - VOLUMES=1
    - EVENTS=1
    - POST=1
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock:ro
```

### 4. Cloudflare Tunnel (Optional)

**Decision**: Add optional Cloudflare Tunnel support via TUNNEL_TOKEN environment variable.

**Rationale**:
- Secure external access without opening ports
- No port forwarding required
- DDoS protection via Cloudflare
- Optional: users can opt-in by setting token

**Implementation**:
```yaml
# Optional - uncomment and set TUNNEL_TOKEN to enable
# cloudflared:
#   image: cloudflare/cloudflared:latest
#   environment:
#     - TUNNEL_TOKEN=${TUNNEL_TOKEN}
#   command: tunnel --no-autoupdate run --token ${TUNNEL_TOKEN}
```

### 5. New *arr Ecosystem Tools

| Service | Image | Port | Purpose |
|---------|-------|------|---------|
| Huntarr | huntarr/huntarr:latest | 9705 | Find missing content, upgrade quality |
| Recommendarr | tannermiddleton/recommendarr:latest | 3000 | AI-powered media recommendations |
| Boxarr | iongpt/boxarr:latest | 5055 | Box office tracking for Radarr |
| Profilarr | santiagosayshey/profilarr:latest | 6868 | Quality profile management |
| Configarr | ghcr.io/raydak-labs/configarr:latest | - | Configuration management |
| Jackett | lscr.io/linuxserver/jackett:latest | 9117 | Indexer proxy |
| Jellystat | cyfershepard/jellystat:latest | 3100 | Jellyfin statistics |

**Note**: Jellystat requires PostgreSQL database.

### 6. Lidarr/Readarr Removal

**Decision**: Remove Lidarr and Readarr to simplify stack focus.

**Rationale**:
- Music and book management less commonly used
- Reduces maintenance burden
- AUDIO and BOOKS paths preserved for Jellyfin native libraries
- Users who need these can add them manually

## Risks / Trade-offs

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Plex users lose libraries | High | High | Document Jellyfin library setup clearly |
| Jellystat PostgreSQL complexity | Medium | Low | Include PostgreSQL in compose |
| Dockhand maturity | Low | Medium | Actively maintained, good community |
| Cloudflare Tunnel requires account | Medium | Low | Keep optional, document setup |
| Huntarr still in development | Medium | Low | Clearly mark as beta in docs |

## Migration Plan

### Pre-Migration (User Actions)
1. Export Plex watchlist/favorites (no automated migration available)
2. Note current service ports and credentials
3. Create backup: `./arrgo.sh backup`
4. Ensure sufficient disk space for new images

### Migration Steps
1. Stop all services: `./arrgo.sh stop`
2. Pull new docker-compose.yml
3. Update .env: Remove PLEX_CLAIM, optionally add TUNNEL_TOKEN
4. Pull images: `docker-compose pull`
5. Start services: `./arrgo.sh start`
6. Configure Jellyfin: Create libraries, add users
7. Configure Jellystat: Connect to Jellyfin with API key
8. Configure Dockhand: Recreate stacks as needed
9. Configure new tools: Huntarr, Recommendarr, etc.

### Rollback Plan
1. Stop services
2. Restore backup: `./arrgo.sh restore <backup>`
3. Use previous docker-compose.yml from git
4. Start services

## Open Questions

1. ~~Should we add WUD notification integrations?~~ → Document in post-install
2. ~~Should Jellystat use SQLite or PostgreSQL?~~ → PostgreSQL for reliability
3. Should we provide a Homarr dashboard configuration file with all new services pre-configured?
