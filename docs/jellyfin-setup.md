# Jellyfin Setup Guide

This guide covers the initial setup and configuration of Jellyfin media server in ArrGo.

## Initial Setup

### Accessing Jellyfin

1. Navigate to `http://jellyfin.<domain>` or `http://<server-ip>:8096`
2. You'll be greeted with the setup wizard

### Setup Wizard

#### 1. Language Selection

Select your preferred display language.

#### 2. Create Admin Account

Create an admin user account:

- **Username**: Choose a username (e.g., `admin`)
- **Password**: Set a strong password
- **Important**: Remember these credentials for future access

#### 3. Add Media Libraries

Add your media libraries:

##### Movies Library

```
Name: Movies
Type: Movies
Folders: /movies
```

##### TV Shows Library

```
Name: TV Shows
Type: Shows
Folders: /tv
```

##### Music Library

```
Name: Music
Type: Music
Folders: /music
```

##### Books Library

```
Name: Books
Type: Books
Folders: /books
```

#### 4. Metadata Language

Select your preferred metadata language for:

- Display language
- Country/Region

#### 5. Remote Access

Configure remote access settings:

- **Enable remote connections**: Recommended for external access
- **Enable automatic port mapping**: If using UPnP (not required behind Traefik)

#### 6. Complete Setup

Click **Finish** to complete the wizard.

## Post-Setup Configuration

### Dashboard Access

After setup, access the dashboard at:

- `http://jellyfin.<domain>/web/index.html#!/dashboard.html`
- Or click on your profile → **Dashboard**

### Enable Hardware Transcoding (Optional)

If your server supports hardware transcoding:

1. Go to **Dashboard** → **Playback**
2. Under **Transcoding**:
   - **Hardware acceleration**: Select your hardware (Intel QSV, NVIDIA NVENC, AMD AMF, or VAAPI)
   - **Enable hardware decoding**: Check for supported codecs
   - **Enable tone mapping**: For HDR to SDR conversion

3. Save changes

### Configure Networking

#### Port Configuration

Jellyfin uses the following ports:

| Port | Purpose |
|------|---------|
| 8096 | HTTP Web Interface |
| 8920 | HTTPS Web Interface (optional) |

#### Base URL (if needed)

If running behind a reverse proxy with a subpath:

1. Go to **Dashboard** → **Networking**
2. Set **Base URL** (e.g., `/jellyfin`)
3. Restart Jellyfin

### Add Additional Users

1. Go to **Dashboard** → **Users**
2. Click **Add User**
3. Configure:
   - Username
   - Password
   - Library access permissions
   - Streaming quality limits

### API Key Generation

For services like Jellystat or Seerr:

1. Go to **Dashboard** → **API Keys**
2. Click **Create**
3. Enter an app name (e.g., "Jellystat", "Seerr")
4. Copy the generated API key

## Integration with Other Services

### Seerr Integration

1. In Seerr, go to **Settings** → **Media Servers**
2. Click **Add Media Server**
3. Configure:
   ```
   Name: Jellyfin
   Type: Jellyfin
   URL: http://jellyfin:8096
   API Key: <your-jellyfin-api-key>
   ```
4. Test connection and save

### Jellystat Integration

1. Access Jellystat at `http://jellystat.<domain>`
2. Enter Jellyfin connection details:
   ```
   Server URL: http://jellyfin:8096
   API Key: <your-jellyfin-api-key>
   ```
3. Save and verify connection

### Sonarr/Radarr Integration

1. In Sonarr/Radarr, go to **Settings** → **Connect**
2. Add a new connection: **Jellyfin**
3. Configure:
   ```
   Name: Jellyfin
   URL: http://jellyfin:8096
   API Key: <your-jellyfin-api-key>
   ```
4. Enable notifications for:
   - On Grab
   - On Download
   - On Rename

## Library Organization

### Recommended Folder Structure

```
/movies/
├── Movie Name (Year)/
│   └── Movie Name (Year).mkv

/tv/
├── TV Show Name/
│   ├── Season 01/
│   │   ├── TV Show Name - S01E01.mkv
│   │   └── TV Show Name - S01E02.mkv
│   └── Season 02/

/music/
├── Artist Name/
│   └── Album Name/
│       └── 01 - Track Name.flac

/books/
├── Author Name/
│   └── Book Title.epub
```

### Metadata Providers

Jellyfin uses multiple providers:

- **Movies**: TheMovieDb, OMDb
- **TV Shows**: TheTVDb, TheMovieDb
- **Music**: MusicBrainz, TheAudioDb
- **Books**: OpenLibrary

Configure in **Dashboard** → **Libraries** → [Library] → **Manage Library**

## Advanced Configuration

### Theme Customization

Jellyfin uses theme.park with the `TP_THEME` environment variable:

```yaml
environment:
  - DOCKER_MODS=ghcr.io/themepark-dev/theme.park:jellyfin
  - TP_THEME=nord
```

Available themes: `dark`, `nord`, `dracula`, `aquamarine`, `plex`, `maroon`, `space-gray`

### Hardware Acceleration

#### Intel Quick Sync (QSV)

```yaml
devices:
  - /dev/dri:/dev/dri
environment:
  - PUID=1000
  - PGID=1000
```

#### NVIDIA GPU

```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: all
          capabilities: [gpu]
```

### Reverse Proxy Configuration

Jellyfin is pre-configured with Traefik labels:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.jellyfin.rule=Host(`jellyfin.<domain>`)"
  - "traefik.http.services.jellyfin.loadbalancer.server.port=8096"
```

## Troubleshooting

### Jellyfin Not Accessible

1. Check container status: `docker ps | grep jellyfin`
2. View logs: `docker logs jellyfin`
3. Verify port 8096 is available
4. Check Traefik routing

### Hardware Transcoding Not Working

1. Verify device is accessible: `ls -la /dev/dri`
2. Check user permissions (PUID/PGID)
3. Verify driver installation: `vainfo` (for Intel)

### Library Not Scanning

1. Check folder permissions
2. Verify path mapping in docker-compose
3. Trigger manual scan: **Dashboard** → **Libraries** → **Scan All Libraries**

### Poor Playback Performance

1. Enable hardware transcoding
2. Adjust streaming quality in user settings
3. Check network bandwidth
4. Review transcoding logs

## Migration from Plex

If migrating from Plex, see [Migration Guide](migration.md) for:

- Watch history migration options
- Library reorganization
- User account recreation
- Playlist migration

## Additional Resources

- [Jellyfin Documentation](https://jellyfin.org/docs/)
- [Jellyfin Forum](https://forum.jellyfin.org/)
- [Hardware Acceleration Guide](https://jellyfin.org/docs/general/administration/hardware-acceleration)
