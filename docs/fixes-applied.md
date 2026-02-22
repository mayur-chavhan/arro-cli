# Configuration Fixes Applied - Action Required

## Overview

Multiple configuration issues have been identified and fixed in the ArrGo stack. **You must regenerate configuration files** to apply these fixes.

## Issues Fixed

### 1. Homepage API Keys Not Working ✅
**Problem**: Homepage widgets showed errors for all services due to API keys not being properly written to config files.

**Root Cause**: The `generate-configs.sh` script was writing literal `${HOMEPAGE_VAR_*}` placeholders instead of actual API key values.

**Fix**: Modified script to write actual API key values to `homepage/services.yaml` (commit `f34d872`).

**Status**: Fixed - requires regeneration.

---

### 2. Homepage Service URLs Using Wrong Format ✅
**Problem**: Clicking service links from homepage redirected to Traefik hostnames (e.g., `http://jellyfin.192.168.1.11.nip.io`) which don't work with direct IP access.

**Root Cause**: All URLs were hardcoded to use Traefik hostname format regardless of access method.

**Fix**: Added intelligent URL routing:
- **For localhost or IP addresses**: Uses direct `http://IP:PORT` format
- **For custom domains**: Uses Traefik `http://service.domain` format

**Status**: Fixed - requires regeneration.

---

### 3. Jackett Redirect Loop ✅
**Problem**: Accessing Jackett via IP:port redirected to `http://jackett/UI/Dashboard`.

**Root Cause**: `BasePathOverride` was set even when not using a reverse proxy path.

**Fix**: Only set `BasePathOverride` when `BASE_PATH` is explicitly configured (commit `5ffba7b`).

**Status**: Fixed - requires regeneration and container restart.

---

### 4. JELLYFIN_API_KEY and SEERR_API_KEY Not Auto-Generated ⚠️
**Problem**: Homepage Jellyfin and Seerr widgets show 401 errors.

**Root Cause**: These API keys **CANNOT** be auto-generated - they must be obtained from the service UIs.

**Fix**: Added comprehensive documentation to `.env.example` with step-by-step instructions.

**Status**: **Requires manual action** (see below).

---

### 5. Seerr Configuration Management ✅
**Problem**: Auto-generated Seerr configuration was conflicting with manual UI setup, causing connection issues.

**Root Cause**: The `generate-configs.sh` script was creating a `settings.json` file that Seerr would try to use, conflicting with user's manual configuration through the UI.

**Fix**: Disabled automatic Seerr config generation. The script now only creates the empty config directory for volume mounting. Users configure Seerr entirely through its web UI.

**Status**: Fixed - Seerr configuration is now 100% manual via UI.

---

### 6. Boxarr Port Misconfiguration ✅
**Problem**: User reported port 5656 unreachable, then connection refused on 5056.

**Root Cause**: docker-compose.yml had incorrect port mapping `5056:5056`. Boxarr's internal port is `8888`, not `5056`.

**Fix**: Changed port mapping to `5056:8888` and updated Traefik loadbalancer to use port `8888`.

**Status**: Fixed - Boxarr now accessible at `http://YOUR_IP:5056`.

---

## Required Actions

### Step 1: Obtain Manual API Keys (CRITICAL)

#### A. Get JELLYFIN_API_KEY

1. Access Jellyfin: `http://192.168.1.11:8096`
2. Complete initial setup if not done
3. Go to **Dashboard** → **API Keys** → **Create new API key**
4. Name it: `ArrGo` or `Homepage`
5. Copy the generated key

#### B. Configure Seerr and Get API Key

**IMPORTANT**: Seerr is now configured entirely through its web UI. No config files are auto-generated.

1. Access Seerr: `http://192.168.1.11:5055`
2. Complete initial setup wizard:
   - Connect to Jellyfin:
     - Server URL: `http://jellyfin:8096` (internal Docker network)
     - Or external: `http://192.168.1.11:8096`
   - Enter your Jellyfin admin credentials
   - Configure Radarr and Sonarr connections (use the API keys from `.env`)
   - Create Seerr admin account
3. After setup, go to **Settings** → **General** → **API Key**
4. Copy the displayed key

#### C. Update .env File

Edit your `.env` file and add the keys:

```bash
JELLYFIN_API_KEY=your-jellyfin-api-key-here
SEERR_API_KEY=your-seerr-api-key-here
```

---

### Step 2: Regenerate Configuration Files

Run the configuration generator:

```bash
./generate-configs.sh
```

This will:
- Regenerate homepage `services.yaml` with correct API keys
- Update all URLs to use proper format for your DOMAIN setting
- Fix Jackett BasePathOverride
- Create Seerr config directory (but no config files - Seerr manages its own config)
- Write updated values to `.env`

---

### Step 3: Restart Affected Containers

Restart containers to load new configurations:

```bash
docker compose restart homepage jackett
```

**Note**: No need to restart Seerr - it manages its own configuration through the UI.

Or restart all services:

```bash
docker compose restart
```

---

### Step 4: Verify Fixes

1. **Homepage Widgets**:
   - Access: `http://192.168.1.11:3004`
   - All service widgets should display statistics (no 401 errors)
   - Click any service link - should go directly to `http://192.168.1.11:PORT`

2. **Jackett**:
   - Access: `http://192.168.1.11:9117`
   - Should load dashboard without redirect issues

3. **Seerr + Jellyfin**:
   - Access: `http://192.168.1.11:5055`
   - Go to Settings → Jellyfin
   - Connection status should be green/working

4. **Boxarr**:
   - Access: `http://192.168.1.11:5056` (NOT 5656!)

---

## Service Port Reference

For direct IP access, use these ports:

| Service       | Port | URL                          |
|---------------|------|------------------------------|
| Traefik       | 80   | http://192.168.1.11:80       |
| Traefik API   | 8082 | http://127.0.0.1:8082        |
| Jellyfin      | 8096 | http://192.168.1.11:8096     |
| Seerr         | 5055 | http://192.168.1.11:5055     |
| Sonarr        | 8989 | http://192.168.1.11:8989     |
| Radarr        | 7878 | http://192.168.1.11:7878     |
| Prowlarr      | 9696 | http://192.168.1.11:9696     |
| Jackett       | 9117 | http://192.168.1.11:9117     |
| Bazarr        | 6767 | http://192.168.1.11:6767     |
| qBittorrent   | 8080 | http://192.168.1.11:8080     |
| Homepage      | 3004 | http://192.168.1.11:3004     |
| Dockhand      | 3002 | http://192.168.1.11:3002     |
| Jellystat     | 3003 | http://192.168.1.11:3003     |
| WUD           | 3000 | http://192.168.1.11:3000     |
| Huntarr       | 9705 | http://192.168.1.11:9705     |
| Recommendarr  | 3001 | http://192.168.1.11:3001     |
| Boxarr        | 5056 | http://192.168.1.11:5056     |
| Profilarr     | 6868 | http://192.168.1.11:6868     |

---

## Troubleshooting

### Homepage still showing 401 errors after regeneration

1. Check `.env` file contains actual API key values (not empty)
2. Verify you restarted homepage container: `docker compose restart homepage`
3. Check homepage logs: `docker logs homepage`

### Jackett still redirecting

1. Verify you ran `./generate-configs.sh` after pulling latest code
2. Check `config/jackett/Jackett/ServerConfig.json` - should NOT contain `BasePathOverride` key
3. Restart jackett: `docker compose restart jackett`

### Seerr cannot connect to Jellyfin

1. Verify `JELLYFIN_API_KEY` is set in `.env`
2. Check Jellyfin is accessible: `curl http://jellyfin:8096/health` (from inside any container)
3. In Seerr UI, use hostname `jellyfin` not `192.168.1.11`

---

## Summary of Commits

- `4e869d9` - Added HOMEPAGE_VAR_* environment variables to homepage service
- `5ffba7b` - Fixed Jackett BasePathOverride conditional logic
- `f34d872` - Fixed generate-configs.sh to write actual API key values
- `[CURRENT]` - Added intelligent URL routing and comprehensive documentation

---

## Need Help?

If issues persist after following these steps:

1. Check logs: `docker compose logs [service-name]`
2. Verify `.env` file has all required keys with actual values
3. Ensure all services are running: `docker compose ps`
4. Review [troubleshooting guide](./troubleshooting.md)
