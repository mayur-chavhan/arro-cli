# Migration Guide

## Migrating to v3.0.0 (Jellyfin Stack)

This guide covers migrating from the Plex-based stack to the new Jellyfin-based stack with enhanced security, monitoring, and automation tools.

### Key Changes

| Component | Old | New |
|-----------|-----|-----|
| Media Server | Plex | Jellyfin |
| Container Management | Portainer | Dockhand |
| Security | Direct socket | Docker Socket Proxy |
| Audio/Books | Lidarr/Readarr/Calibre | Removed (Jellyfin native) |
| Monitoring | Basic | Jellystat, Huntarr, Recommendarr, Boxarr, Profilarr |
| Indexer | Prowlarr only | Prowlarr + Jackett |
| External Access | Manual | Cloudflare Tunnel (optional) |

### Pre-Migration Checklist

- [ ] Backup all configurations
- [ ] Export Plex watch history and playlists (if needed)
- [ ] Note current service ports
- [ ] Ensure sufficient disk space
- [ ] Plan for ~15-30 minutes downtime

### Migration Steps

#### 1. Backup Existing Configuration

```bash
# Create backup
./arrgo.sh backup

# Or manually
tar -czvf arrgo-backup-$(date +%Y%m%d).tar.gz config/ .env
```

#### 2. Stop All Services

```bash
./arrgo.sh stop
```

#### 3. Pull Updated Files

```bash
git pull origin main
```

#### 4. Update Environment File

Update your `.env` file with new variables:

```env
# Remove PLEX_CLAIM (no longer needed)
# PLEX_CLAIM=claim-xxxxx

# Add Jellystat database credentials
JELLYSTAT_DB_PASSWORD=your-secure-password
JELLYSTAT_JWT_SECRET=your-jwt-secret

# Optional: Cloudflare Tunnel
# TUNNEL_TOKEN=your-tunnel-token
```

#### 5. Migrate Plex Data to Jellyfin (Optional)

If you want to preserve watch history:

1. Use [Jellyfin Plex Migration Tool](https://github.com/mbullington/jellyfin_plex_migration)
2. Or manually re-add libraries in Jellyfin

#### 6. Pull New Container Images

```bash
docker-compose pull
```

#### 7. Start Services

```bash
./arrgo.sh start
```

#### 8. Verify Services

Check that all services are running:

```bash
./arrgo.sh status
```

### Post-Migration Tasks

#### Jellyfin Setup

1. Navigate to `http://jellyfin.<domain>`
2. Complete the setup wizard
3. Add media libraries (Movies, TV Shows, Music, Books)
4. Configure users and permissions
5. Enable hardware transcoding if available

#### Jellystat Setup

1. Navigate to `http://jellystat.<domain>`
2. Connect to Jellyfin server
3. Configure API key from Jellyfin
4. View statistics dashboard

#### Dockhand Setup

1. Navigate to `http://dockhand.<domain>`
2. View all containers
3. No additional configuration needed - connects via Docker Socket Proxy

#### Docker Socket Proxy

The socket proxy provides secure access to Docker API:

- Traefik, WUD, and Dockhand connect through it
- No direct socket mounts on services
- Restricts API access to allowed operations

#### Seerr Configuration

Update Seerr to use Jellyfin:

1. Navigate to `http://seerr.<domain>`
2. Go to Settings > Media Servers
3. Remove Plex server
4. Add Jellyfin server
5. Configure libraries

#### New Services

| Service | URL | Purpose |
|---------|-----|---------|
| Jellystat | `http://jellystat.<domain>` | Jellyfin statistics |
| Huntarr | `http://huntarr.<domain>` | Media hunting automation |
| Recommendarr | `http://recommendarr.<domain>` | Media recommendations |
| Boxarr | `http://boxarr.<domain>` | Collection management |
| Profilarr | `http://profilarr.<domain>` | Profile management |
| Jackett | `http://jackett.<domain>` | Indexer proxy |

#### Cloudflare Tunnel (Optional)

To enable Cloudflare Tunnel for secure external access:

1. Create a tunnel at [Cloudflare Zero Trust](https://one.dash.cloudflare.com/)
2. Get your tunnel token
3. Add to `.env`:

```env
TUNNEL_TOKEN=your-tunnel-token
```

4. Enable the service:

```bash
docker-compose --profile cloudflare up -d cloudflared
```

### Troubleshooting

#### Jellyfin Connection Issues

If Jellyfin is not accessible:

1. Check container logs: `docker logs jellyfin`
2. Verify port 8096 is available
3. Check Traefik routing labels

#### Dockhand Permission Issues

If Dockhand cannot manage containers:

1. Verify Docker Socket Proxy is running
2. Check proxy environment variables
3. Ensure network connectivity between services

#### Jellystat Database Issues

If Jellystat fails to start:

1. Verify PostgreSQL container is running: `docker logs jellystat-db`
2. Check database password matches in both services
3. Ensure data volume is writable

#### Seerr Jellyfin Connection

If Seerr cannot connect to Jellyfin:

1. Verify Jellyfin is running and accessible
2. Use internal Docker network URL: `http://jellyfin:8096`
3. Generate API key in Jellyfin Dashboard > API Keys

### Rollback

If issues occur, rollback to the previous version:

```bash
# Stop services
./arrgo.sh stop

# Restore backup
./arrgo.sh restore backups/arrgo-backup-YYYYMMDD.tar.gz

# Or manually
git checkout <previous-commit>
docker-compose pull
./arrgo.sh start
```

---

## Migrating to 2026 Stack (v2.0.0)

This guide covers migrating from the original ArrGo stack to the updated 2026 version with Traefik v3, WUD, Seerr, and dark themes.

### Key Changes

| Component | Old | New |
|-----------|-----|-----|
| Traefik | v2.10 | v3.3 |
| Update Manager | Watchtower | WUD (What's Up Docker) |
| Media Requests | Overseerr | Seerr |
| Readarr Image | linuxserver/readarr:develop | hotio/readarr:latest |
| Dark Themes | Not included | theme.park (default: nord) |

### Pre-Migration Checklist

- [ ] Backup all configurations
- [ ] Note current service ports
- [ ] Ensure sufficient disk space
- [ ] Plan for ~10-15 minutes downtime

### Migration Steps

#### 1. Backup Existing Configuration

```bash
# Create backup
./arrgo.sh backup

# Or manually
tar -czvf arrgo-backup-$(date +%Y%m%d).tar.gz config/ .env
```

#### 2. Stop All Services

```bash
./arrgo.sh stop
```

#### 3. Pull Updated Files

```bash
git pull origin main
```

#### 4. Update Environment File

Add these new variables to your `.env` file:

```env
# User/Group IDs
PUID=1000  # Run 'id -u' to get your user ID
PGID=1000  # Run 'id -g' to get your group ID

# Theme Configuration
TP_THEME=nord  # Options: dark, nord, dracula, aquamarine, plex, maroon, space-gray
```

#### 5. Pull New Container Images

```bash
docker-compose pull
```

#### 6. Start Services

```bash
./arrgo.sh start
```

#### 7. Verify Services

Check that all services are running:

```bash
./arrgo.sh status
```

### Post-Migration Tasks

#### Traefik v3

Traefik v3 includes v2 compatibility mode (`core.defaultRuleSyntax: v2`), so existing routing rules should work without modification. Verify:

1. Access Traefik dashboard at `http://<domain>/`
2. Check all services are listed and routing correctly

#### WUD (What's Up Docker)

WUD replaces Watchtower. Access the dashboard:

1. Navigate to `http://wud.<domain>`
2. View all containers and their update status
3. Configure notifications (Discord, Telegram, etc.) in the UI or docker-compose.yml

#### Seerr

Seerr replaces Overseerr. Your existing configuration is preserved:

1. Navigate to `http://seerr.<domain>`
2. All settings, users, and requests should be intact
3. Configuration stored in `config/overseerr/` (same location)

#### Dark Themes

Dark themes are automatically applied to supported services via theme.park:

- Sonarr, Radarr, Lidarr, Readarr, Prowlarr, Bazarr
- qBittorrent
- Seerr

To change the theme, update `TP_THEME` in your `.env` file and restart:

```bash
# Available themes: dark, nord, dracula, aquamarine, plex, maroon, space-gray
TP_THEME=dracula

# Restart to apply
./arrgo.sh restart
```

To disable themes, remove the `DOCKER_MODS` and `TP_THEME` environment variables from the service in `docker-compose.yml`.

### Troubleshooting

#### Traefik Routing Issues

If services are not accessible after migration:

1. Check Traefik logs: `docker logs traefik`
2. Verify network: `docker network inspect media_network`
3. Check labels: `docker inspect <service-name> --format='{{json .Config.Labels}}'`

#### Seerr Connection Issues

If Seerr cannot connect to Plex or Sonarr/Radarr:

1. Verify services are running: `docker ps`
2. Check Seerr logs: `docker logs seerr`
3. Re-configure connections in Seerr settings

#### Theme Not Applied

If dark themes are not appearing:

1. Clear browser cache
2. Verify `DOCKER_MODS` environment variable is set
3. Check container logs for theme.park errors
4. Restart the affected service

### Rollback

If issues occur, rollback to the previous version:

```bash
# Stop services
./arrgo.sh stop

# Restore backup
./arrgo.sh restore backups/arrgo-backup-YYYYMMDD.tar.gz

# Or manually
git checkout <previous-commit>
docker-compose pull
./arrgo.sh start
```

### Getting Help

- Check logs: `./arrgo.sh logs <service>`
- Review [Troubleshooting Guide](troubleshooting.md)
- Open an issue on GitHub
