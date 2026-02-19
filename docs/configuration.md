# Configuration Guide

## Environment Configuration

### Core Settings

```env
# System
TZ=UTC                     # Your timezone
DOMAIN=localhost           # Your domain name
BASE_PATH=/               # Base URL path

# Paths
CONFIG_ROOT=./config      # Configuration storage
STORAGE_ROOT=/path/to/storage  # Media storage

# Ports
TRAEFIK_PORT=80           # Main web port
```

### Media Paths

```env
# Internal container paths (don't change)
MOVIES_PATH=/movies
SERIES_PATH=/tv
BOOKS_PATH=/books
MUSIC_PATH=/music
DOWNLOADS_PATH=/downloads

# Download Categories
QB_CATEGORY_TV=tv-sonarr
QB_CATEGORY_MOVIES=movies-radarr
```

### Service Configuration

```env
# Jellystat
JELLYSTAT_DB_PASSWORD=your-secure-password
JELLYSTAT_JWT_SECRET=your-jwt-secret

# Cloudflare Tunnel (optional)
TUNNEL_TOKEN=your-tunnel-token
```

## Service Configurations

### Traefik Configuration

Location: `config/traefik/traefik.yml`

```yaml
api:
  dashboard: true
  insecure: true # Change in production

entryPoints:
  web:
    address: ":80"

providers:
  docker:
    endpoint: "tcp://docker-socket-proxy:2375"
    exposedByDefault: false
```

### Docker Socket Proxy Configuration

The Docker Socket Proxy provides secure access to Docker API:

```yaml
docker-socket-proxy:
  image: tecnativa/docker-socket-proxy
  environment:
    - CONTAINERS=1
    - IMAGES=1
    - NETWORKS=1
    - VOLUMES=1
    - POST=0  # Read-only by default
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock:ro
```

Services connect via:
```yaml
environment:
  - DOCKER_HOST=tcp://docker-socket-proxy:2375
```

### qBittorrent Configuration

Location: `config/qbittorrent/qBittorrent.conf`

```ini
[Preferences]
Downloads\SavePath=/downloads/complete
Downloads\TempPath=/downloads/incomplete
WebUI\Port=8080
```

### Media Managers Configuration

Common settings for Sonarr, Radarr:

```xml
<Config>
  <LogLevel>info</LogLevel>
  <UpdateMechanism>Docker</UpdateMechanism>
  <Branch>main</Branch>
  <AnalyticsEnabled>False</AnalyticsEnabled>
  <SslPort>0</SslPort>
</Config>
```

### Jellystat Configuration

Jellystat requires PostgreSQL:

```yaml
jellystat-db:
  image: postgres:15
  environment:
    - POSTGRES_USER=jellystat
    - POSTGRES_PASSWORD=${JELLYSTAT_DB_PASSWORD}
    - POSTGRES_DB=jellystat

jellystat:
  image: cyfersheep/jellystat
  environment:
    - POSTGRES_USER=jellystat
    - POSTGRES_PASSWORD=${JELLYSTAT_DB_PASSWORD}
    - POSTGRES_IP=jellystat-db
    - POSTGRES_PORT=5432
    - JWT_SECRET=${JELLYSTAT_JWT_SECRET}
```

## Network Configuration

### Internal Network

- Network Name: `media_network`
- All services communicate internally
- Only necessary ports exposed

### External Access

1. Domain Setup:

```env
DOMAIN=your.domain.com
```

2. SSL Configuration (optional):

```yaml
# traefik.yml
certificatesResolvers:
  letsencrypt:
    acme:
      email: your@email.com
      storage: acme.json
      httpChallenge:
        entryPoint: web
```

## Storage Configuration

### Directory Structure

```bash
storage/
├── MOVIES/
├── SERIES/
├── AUDIO/
├── BOOKS/
└── TORRENTS/
    ├── COMPLETE/
    │   ├── movies-radarr/
    │   └── tv-sonarr/
    └── INCOMPLETE/
```

### Permissions

```bash
# Set correct permissions
chmod -R 755 config/
chmod -R 755 storage/
chown -R $USER:$USER config/ storage/
```

## Backup Configuration

### Backup Locations

- Configurations: `backups/`
- Created by: `./arrgo.sh backup`
- Naming: `backup_YYYYMMDD_HHMMSS.tar.gz`

### Backup Settings

```bash
# Included in backups:
- Service configurations
- API keys
- Custom scripts
- User settings

# Excluded:
- Media files
- Download files
- Temporary data
```

## Advanced Configuration

### Custom Scripts

Location: `config/scripts/`

```bash
# Example: Post-processing script
#!/bin/bash
# custom-script.sh
# Add your custom logic here
```

### Resource Limits

In `docker-compose.yml`:

```yaml
services:
  jellyfin:
    deploy:
      resources:
        limits:
          cpus: "4"
          memory: 4G
```

### Notification Setup

```env
# Notification Options:
- Discord
- Telegram
- Email
- Slack
- Custom webhook

# Example Discord setup:
NOTIFICATION_URL=discord://webhook-url
```

## Security Configuration

### Authentication

```yaml
# Basic Auth Example
traefik:
  labels:
    - "traefik.http.middlewares.auth.basicauth.users=user:$$apr1$$xyz..."
```

### API Keys

Generated automatically for:

- Sonarr
- Radarr
- Prowlarr
- Jackett

### Network Security

```yaml
# Restrict external access
services:
  service-name:
    networks:
      - media_network
    expose:
      - "internal_port"
```

## Monitoring Configuration

### Health Checks

```yaml
# Docker health checks
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:port"]
  interval: 30s
  timeout: 10s
  retries: 3
```

### Logging

```yaml
# Docker logging
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

## Theming Configuration

ArrGo includes [theme.park](https://theme-park.dev/) integration for dark themes across all supported services.

### Available Themes

| Theme | Description |
|-------|-------------|
| `dark` | Basic dark theme |
| `nord` | Nord color scheme (default) |
| `dracula` | Dracula color scheme |
| `aquamarine` | Blue-green accents |
| `plex` | Plex-style dark theme |
| `maroon` | Dark red accents |
| `space-gray` | Gray tones |

### Setting the Theme

Add to your `.env` file:

```env
TP_THEME=nord
```

Or set directly in docker-compose.yml:

```yaml
environment:
  - TP_THEME=dracula
```

### Supported Services

Dark themes are applied to the following services via `DOCKER_MODS`:

- **Jellyfin** - `ghcr.io/themepark-dev/theme.park:jellyfin`
- **Sonarr** - `ghcr.io/themepark-dev/theme.park:sonarr`
- **Radarr** - `ghcr.io/themepark-dev/theme.park:radarr`
- **Prowlarr** - `ghcr.io/themepark-dev/theme.park:prowlarr`
- **Bazarr** - `ghcr.io/themepark-dev/theme.park:bazarr`
- **Jackett** - `ghcr.io/themepark-dev/theme.park:jackett`
- **qBittorrent** - `ghcr.io/themepark-dev/theme.park:qbittorrent`
- **Seerr** - `ghcr.io/themepark-dev/theme.park:overseerr`

### Disabling Themes

To disable theming for a specific service, remove the `DOCKER_MODS` and `TP_THEME` environment variables:

```yaml
sonarr:
  environment:
    <<: *commonenv
    # Remove or comment out:
    # DOCKER_MODS: ghcr.io/themepark-dev/theme.park:sonarr
    # TP_THEME: nord
```

### Custom CSS

For advanced customization, you can add custom CSS:

```yaml
environment:
  - DOCKER_MODS=ghcr.io/themepark-dev/theme.park:sonarr
  - TP_THEME=nord
  - TP_ADDITIONAL_CSS=/path/to/custom.css
```

### Troubleshooting

If themes are not applied:

1. Clear browser cache (Ctrl+Shift+R / Cmd+Shift+R)
2. Restart the container: `docker restart <service-name>`
3. Check container logs: `docker logs <service-name>`
4. Verify environment variables are set: `docker inspect <service-name> | grep -A5 Env`

## Troubleshooting Configuration

### Debug Mode

```env
# Enable debug logging
LOG_LEVEL=debug
```

### Service Logs

```bash
# View specific service logs
./arrgo.sh logs service-name

# View all logs
./arrgo.sh logs
```

Remember to restart services after configuration changes:

```bash
./arrgo.sh restart
```