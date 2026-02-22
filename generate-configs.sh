#!/usr/bin/env bash

set -e

FORCE=false
for arg in "$@"; do
    case $arg in
        --force|-f) FORCE=true ;;
    esac
done

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

mkdir -p logs

log() {
    local level=$1
    shift
    local msg="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${!level}[${level}]${NC} ${timestamp} - $msg" >&2 | tee -a logs/config-gen.log
}

create_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        log "BLUE" "Created directory: $dir" >&2
    fi
}

create_file() {
    local file="$1"
    local content="$2"
    create_dir "$(dirname "$file")" >&2
    if [ -f "$file" ] && [ "$FORCE" != "true" ]; then
        log "YELLOW" "Skipping existing file (use --force to overwrite): $file" >&2
        return 0
    fi
    echo "$content" > "$file"
    log "BLUE" "Created file: $file" >&2
}

# Read existing API key from a config file to avoid regenerating on re-runs.
# For XML config.xml: extracts <ApiKey>...</ApiKey>
# For JSON ServerConfig.json: extracts "APIKey": "..."
# Returns empty string if file doesn't exist or key not found.
read_existing_xml_key() {
    local file="$1"
    if [ -f "$file" ]; then
        sed -n 's/.*<ApiKey>\(.*\)<\/ApiKey>.*/\1/p' "$file" 2>/dev/null || true
    fi
}

read_existing_json_key() {
    local file="$1"
    local field="$2"
    if [ -f "$file" ]; then
        sed -n "s/.*\"${field}\": *\"\([^\"]*\)\".*/\1/p" "$file" 2>/dev/null || true
    fi
}

read_existing_yaml_key() {
    local file="$1"
    local section="$2"
    local key="$3"
    if [ -f "$file" ]; then
        awk "/^${section}:/{found=1; next} found && /^  ${key}: /{val=\$2; gsub(/^'|'$/, \"\", val); print val; exit} found && /^[^ ]/{exit}" "$file" 2>/dev/null || true
    fi
}

# Sync API keys into pre-filled SQLite databases.
# When using --defaults install, the DBs have baked-in keys that must match config.xml.
# When generate-configs.sh runs (standard install), it creates new keys that must be
# injected into the DBs so integrations work out of the box.
sync_prowlarr_db_keys() {
    local prowlarr_db="$CONFIG_ROOT/prowlarr/prowlarr.db"
    local radarr_api_key="$1"
    local sonarr_api_key="$2"
    
    if [ ! -f "$prowlarr_db" ]; then
        return 0
    fi
    
    if ! command -v sqlite3 &>/dev/null; then
        log "YELLOW" "sqlite3 not found, skipping Prowlarr DB key sync"
        return 0
    fi
    
    log "BLUE" "Syncing API keys into Prowlarr database..."
    sqlite3 "$prowlarr_db" "UPDATE Applications SET Settings = json_set(Settings, '$.apiKey', '${radarr_api_key}') WHERE Implementation = 'Radarr';" 2>/dev/null || true
    sqlite3 "$prowlarr_db" "UPDATE Applications SET Settings = json_set(Settings, '$.apiKey', '${sonarr_api_key}') WHERE Implementation = 'Sonarr';" 2>/dev/null || true
    log "BLUE" "Prowlarr DB keys synced"
}

sync_arr_db_indexer_keys() {
    local service="$1"
    local db_file="$CONFIG_ROOT/${service}/${service}.db"
    local prowlarr_api_key="$2"
    
    if [ ! -f "$db_file" ]; then
        return 0
    fi
    
    if ! command -v sqlite3 &>/dev/null; then
        log "YELLOW" "sqlite3 not found, skipping ${service} DB key sync"
        return 0
    fi
    
    log "BLUE" "Syncing Prowlarr API key into ${service} database..."
    sqlite3 "$db_file" "UPDATE Indexers SET Settings = json_set(Settings, '$.apiKey', '${prowlarr_api_key}') WHERE Name LIKE '%Prowlarr%';" 2>/dev/null || true
    log "BLUE" "${service} DB indexer keys synced"
}

sync_seerr_config_keys() {
    local settings_file="$CONFIG_ROOT/seerr/settings.json"
    local radarr_api_key="$1"
    local sonarr_api_key="$2"
    
    if [ ! -f "$settings_file" ]; then
        return 0
    fi
    
    if command -v python3 &>/dev/null; then
        log "BLUE" "Syncing API keys into Seerr settings..."
        python3 -c "
import json
with open('${settings_file}', 'r') as f:
    data = json.load(f)
for entry in data.get('radarr', []):
    entry['apiKey'] = '${radarr_api_key}'
for entry in data.get('sonarr', []):
    entry['apiKey'] = '${sonarr_api_key}'
with open('${settings_file}', 'w') as f:
    json.dump(data, f, indent=1)
" 2>/dev/null || log "YELLOW" "Failed to update Seerr settings"
    else
        log "YELLOW" "python3 not found, skipping Seerr key sync"
    fi
}

update_env_var() {
    local key=$1
    local value=$2
    local env_file=".env"

    if [ ! -f "$env_file" ]; then
        echo "${key}=${value}" > "$env_file"
        return
    fi

    local temp_file="${env_file}.tmp"
    : > "$temp_file"

    while IFS= read -r line || [ -n "$line" ]; do
        if [[ $line =~ ^$key= ]]; then
            echo "${key}=${value}" >> "$temp_file"
        else
            echo "$line" >> "$temp_file"
        fi
    done < "$env_file"

    mv "$temp_file" "$env_file"
}

generate_qbittorrent_config() {
    local prowlarr_api_key=$1
    local jackett_api_key=$2
    
    create_dir "$CONFIG_ROOT/qbittorrent/qBittorrent"
    create_file "$CONFIG_ROOT/qbittorrent/qBittorrent/qBittorrent.conf" "$(cat << EOF
[AutoRun]
enabled=true
program=unzip "%F" -d "%D"

[BitTorrent]
Session\DefaultSavePath=${DOWNLOADS_PATH}/complete
Session\TempPath=${DOWNLOADS_PATH}/incomplete
Session\Port=6881
Session\MaxRatioAction=0
Session\GlobalMaxRatio=1.0
Session\GlobalMaxSeedingMinutes=-1
Session\MaxRatioAction=PauseIfSeedingTimeReached
Session\GlobalInactiveSeedingTime=0
Session\MaxInactiveSeedingTime=0
Session\ShareLimitAction=0

[Preferences]
WebUI\Port=8080
WebUI\Username=admin
WebUI\Password_PBKDF2="@ByteArray(ARQ77eY1NUZaQsuDHbIMCA==:0WMRkYTUWVT9wVvdDtHAjU9b3b7uB8NR1Gur2hmQCvCDpm39Q+PsJRJPaCU51dEiz+dTzh8qbPsL8WkFljQYFQ==)"
WebUI\Address=*
WebUI\ServerDomains=*
WebUI\UseUPnP=false
WebUI\RootFolder=${BASE_PATH:-}/qbittorrent
Connection\UPnP=false
Downloads\SavePath=${DOWNLOADS_PATH}/complete
Downloads\TempPath=${DOWNLOADS_PATH}/incomplete
Downloads\PreAllocation=true
Downloads\UseIncompleteExtension=true
Queueing\QueueingEnabled=false

[LegalNotice]
Accepted=true

[General]
Configuration\Backup\DeleteOld=false
EOF
)"

    create_file "$CONFIG_ROOT/qbittorrent/qBittorrent/categories.json" "$(cat << EOF
{
    "${QB_CATEGORY_TV}": {
        "save_path": "${DOWNLOADS_PATH}/complete/${QB_CATEGORY_TV}"
    },
    "${QB_CATEGORY_MOVIES}": {
        "save_path": "${DOWNLOADS_PATH}/complete/${QB_CATEGORY_MOVIES}"
    }
}
EOF
)"

    create_dir "$CONFIG_ROOT/qbittorrent/qBittorrent/nova/engines"
    
    create_file "$CONFIG_ROOT/qbittorrent/qBittorrent/nova/engines/prowlarr.json" "$(cat << EOF
{
    "api_key": "${prowlarr_api_key}",
    "url": "http://prowlarr:9696"
}
EOF
)"

    create_file "$CONFIG_ROOT/qbittorrent/qBittorrent/nova/engines/jackett.json" "$(cat << EOF
{
    "api_key": "${jackett_api_key}",
    "url": "http://jackett:9117",
    "indexer": "all"
}
EOF
)"
}

generate_prowlarr_config() {
    local config_file="$CONFIG_ROOT/prowlarr/config.xml"
    local existing_key
    existing_key=$(read_existing_xml_key "$config_file")
    local api_key="${existing_key:-$(openssl rand -hex 32)}"
    
    create_dir "$CONFIG_ROOT/prowlarr"
    create_file "$CONFIG_ROOT/prowlarr/config.xml" "$(cat << EOF
<?xml version="1.0" encoding="utf-8"?>
<Config>
  <LogLevel>info</LogLevel>
  <UpdateMechanism>Docker</UpdateMechanism>
  <UrlBase>${BASE_PATH:-}/prowlarr</UrlBase>
  <Branch>main</Branch>
  <Port>9696</Port>
  <BindAddress>*</BindAddress>
  <ApiKey>${api_key}</ApiKey>
  <AuthenticationMethod>None</AuthenticationMethod>
  <AnalyticsEnabled>False</AnalyticsEnabled>
  <SslPort>0</SslPort>
  <EnableSsl>False</EnableSsl>
  <LaunchBrowser>False</LaunchBrowser>
  <InstanceName>Prowlarr</InstanceName>
</Config>
EOF
)"
    printf "%s" "$api_key"
}

generate_jackett_config() {
    local config_file="$CONFIG_ROOT/jackett/Jackett/ServerConfig.json"
    local existing_key
    existing_key=$(read_existing_json_key "$config_file" "APIKey")
    local api_key="${existing_key:-$(openssl rand -hex 32)}"
    
    local base_path=""
    if [ -n "$BASE_PATH" ] && [ "$BASE_PATH" != "/" ]; then
        base_path="\"BasePathOverride\": \"${BASE_PATH}/jackett\","
    fi
    
    create_dir "$CONFIG_ROOT/jackett"
    create_file "$CONFIG_ROOT/jackett/Jackett/ServerConfig.json" "$(cat << EOF
{
  "Port": 9117,
  "AllowExternal": true,
  "APIKey": "${api_key}",
  "AdminPassword": "",
  "InstanceId": "$(uuidgen | tr '[:upper:]' '[:lower:]')",
  "BlackholeDir": "",
  "UpdateDisabled": true,
  "UpdatePrerelease": false,
  ${base_path}
  "OmdbApiKey": "",
  "OmdbApiUrl": ""
}
EOF
)"
    printf "%s" "$api_key"
}

generate_sonarr_config() {
    local config_file="$CONFIG_ROOT/sonarr/config.xml"
    local existing_key
    existing_key=$(read_existing_xml_key "$config_file")
    local api_key="${existing_key:-$(openssl rand -hex 32)}"
    
    create_dir "$CONFIG_ROOT/sonarr"
    create_file "$CONFIG_ROOT/sonarr/config.xml" "$(cat << EOF
<?xml version="1.0" encoding="utf-8"?>
<Config>
  <LogLevel>info</LogLevel>
  <UpdateMechanism>Docker</UpdateMechanism>
  <UrlBase>${BASE_PATH:-}/sonarr</UrlBase>
  <Branch>main</Branch>
  <Port>8989</Port>
  <BindAddress>*</BindAddress>
  <ApiKey>${api_key}</ApiKey>
  <AuthenticationMethod>None</AuthenticationMethod>
  <AnalyticsEnabled>False</AnalyticsEnabled>
  <SslPort>0</SslPort>
  <EnableSsl>False</EnableSsl>
  <LaunchBrowser>False</LaunchBrowser>
</Config>
EOF
)"

    create_dir "$CONFIG_ROOT/sonarr/config"
    
    create_file "$CONFIG_ROOT/sonarr/config/mediamanagement.json" "$(cat << EOF
{
  "autoUnmonitorPreviouslyDownloadedEpisodes": false,
  "recycleBin": "",
  "recycleBinCleanupDays": 7,
  "downloadPropersAndRepacks": "preferAndUpgrade",
  "createEmptySeriesFolders": false,
  "deleteEmptyFolders": true,
  "fileDate": "none",
  "rescanAfterRefresh": "always",
  "setPermissionsLinux": true,
  "chmodFolder": "755",
  "skipFreeSpaceCheckWhenImporting": false,
  "minimumFreeSpaceWhenImporting": 100,
  "copyUsingHardlinks": true,
  "importExtraFiles": true,
  "extraFileExtensions": "srt,sub,idx,nfo",
  "enableMediaInfo": true,
  "defaultRootFolderPath": "${SERIES_PATH}"
}
EOF
)"

    create_file "$CONFIG_ROOT/sonarr/config/downloadclient.json" "$(cat << EOF
{
  "downloadClientConfigs": [
    {
      "enable": true,
      "protocol": "torrent",
      "priority": 1,
      "name": "qBittorrent",
      "implementation": "QBittorrent",
      "configContract": "QBittorrentSettings",
      "host": "qbittorrent",
      "port": 8080,
      "username": "admin",
      "password": "adminadmin",
      "category": "${QB_CATEGORY_TV}",
      "removeCompletedDownloads": ${DELETE_AFTER_SEED:-false},
      "removeFailedDownloads": true
    }
  ]
}
EOF
)"

    printf "%s" "$api_key"
}

generate_sonarr_indexers() {
    local prowlarr_api_key=$1
    local jackett_api_key=$2
    
    create_file "$CONFIG_ROOT/sonarr/config/indexers.json" "$(cat << EOF
{
  "indexerConfigs": [
    {
      "enable": true,
      "name": "Prowlarr",
      "implementation": "Newznab",
      "configContract": "NewznabSettings",
      "priority": 25,
      "enableRss": true,
      "enableAutomaticSearch": true,
      "enableInteractiveSearch": true,
      "settings": {
        "baseUrl": "http://prowlarr:9696",
        "apiPath": "/api",
        "apiKey": "${prowlarr_api_key}",
        "categories": [5000, 5030, 5040]
      }
    },
    {
      "enable": true,
      "name": "Jackett",
      "implementation": "Torznab",
      "configContract": "TorznabSettings",
      "priority": 25,
      "enableRss": true,
      "enableAutomaticSearch": true,
      "enableInteractiveSearch": true,
      "settings": {
        "baseUrl": "http://jackett:9117/torznab/all/api",
        "apiPath": "/api",
        "apiKey": "${jackett_api_key}",
        "categories": [5000, 5030, 5040]
      }
    }
  ]
}
EOF
)"
}

generate_radarr_config() {
    local config_file="$CONFIG_ROOT/radarr/config.xml"
    local existing_key
    existing_key=$(read_existing_xml_key "$config_file")
    local api_key="${existing_key:-$(openssl rand -hex 32)}"
    
    create_dir "$CONFIG_ROOT/radarr"
    create_file "$CONFIG_ROOT/radarr/config.xml" "$(cat << EOF
<?xml version="1.0" encoding="utf-8"?>
<Config>
  <LogLevel>info</LogLevel>
  <UpdateMechanism>Docker</UpdateMechanism>
  <UrlBase>${BASE_PATH:-}/radarr</UrlBase>
  <Branch>main</Branch>
  <Port>7878</Port>
  <BindAddress>*</BindAddress>
  <ApiKey>${api_key}</ApiKey>
  <AuthenticationMethod>None</AuthenticationMethod>
  <AnalyticsEnabled>False</AnalyticsEnabled>
  <SslPort>0</SslPort>
  <EnableSsl>False</EnableSsl>
  <LaunchBrowser>False</LaunchBrowser>
</Config>
EOF
)"

    create_dir "$CONFIG_ROOT/radarr/config"
    
    create_file "$CONFIG_ROOT/radarr/config/mediamanagement.json" "$(cat << EOF
{
  "autoUnmonitorPreviouslyDownloadedMovies": false,
  "recycleBin": "",
  "recycleBinCleanupDays": 7,
  "downloadPropersAndRepacks": "preferAndUpgrade",
  "createEmptyMovieFolders": false,
  "deleteEmptyFolders": true,
  "fileDate": "none",
  "rescanAfterRefresh": "always",
  "setPermissionsLinux": true,
  "chmodFolder": "755",
  "skipFreeSpaceCheckWhenImporting": false,
  "minimumFreeSpaceWhenImporting": 100,
  "copyUsingHardlinks": true,
  "importExtraFiles": true,
  "extraFileExtensions": "srt,sub,idx,nfo",
  "enableMediaInfo": true,
  "defaultRootFolderPath": "${MOVIES_PATH}"
}
EOF
)"

    create_file "$CONFIG_ROOT/radarr/config/downloadclient.json" "$(cat << EOF
{
  "downloadClientConfigs": [
    {
      "enable": true,
      "protocol": "torrent",
      "priority": 1,
      "name": "qBittorrent",
      "implementation": "QBittorrent",
      "configContract": "QBittorrentSettings",
      "host": "qbittorrent",
      "port": 8080,
      "username": "admin",
      "password": "adminadmin",
      "category": "${QB_CATEGORY_MOVIES}",
      "removeCompletedDownloads": ${DELETE_AFTER_SEED:-false},
      "removeFailedDownloads": true
    }
  ]
}
EOF
)"

    printf "%s" "$api_key"
}

generate_radarr_indexers() {
    local prowlarr_api_key=$1
    local jackett_api_key=$2
    
    create_file "$CONFIG_ROOT/radarr/config/indexers.json" "$(cat << EOF
{
  "indexerConfigs": [
    {
      "enable": true,
      "name": "Prowlarr",
      "implementation": "Newznab",
      "configContract": "NewznabSettings",
      "priority": 25,
      "enableRss": true,
      "enableAutomaticSearch": true,
      "enableInteractiveSearch": true,
      "settings": {
        "baseUrl": "http://prowlarr:9696",
        "apiPath": "/api",
        "apiKey": "${prowlarr_api_key}",
        "categories": [2000, 2010, 2020, 2030, 2040, 2045, 2050, 2060, 2070, 2080]
      }
    },
    {
      "enable": true,
      "name": "Jackett",
      "implementation": "Torznab",
      "configContract": "TorznabSettings",
      "priority": 25,
      "enableRss": true,
      "enableAutomaticSearch": true,
      "enableInteractiveSearch": true,
      "settings": {
        "baseUrl": "http://jackett:9117/torznab/all/api",
        "apiPath": "/api",
        "apiKey": "${jackett_api_key}",
        "categories": [2000, 2010, 2020, 2030, 2040, 2045, 2050, 2060, 2070, 2080]
      }
    }
  ]
}
EOF
)"
}

generate_traefik_config() {
    create_file "$CONFIG_ROOT/traefik/traefik.yml" "$(cat << EOF
api:
  dashboard: true
  insecure: true

entryPoints:
  web:
    address: ":80"
    
providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
    watch: true
    network: media_network

log:
  level: "DEBUG"

accessLog: {}
EOF
)"
    create_file "$CONFIG_ROOT/traefik/acme.json" ""
    chmod 600 "$CONFIG_ROOT/traefik/acme.json"
}

generate_deleterr_config() {
    create_file "$CONFIG_ROOT/deleterr/settings.yaml" "$(cat << EOF
jellyfin:
  url: "http://jellyfin:8096"
  api_key: "${JELLYFIN_API_KEY:-}"

radarr:
  - name: "Radarr"
    url: "http://radarr:7878"
    api_key: "${RADARR_API_KEY}"

sonarr:
  - name: "Sonarr"
    url: "http://sonarr:8989"
    api_key: "${SONARR_API_KEY}"

dry_run: true
jellyfin_library_scan_after_actions: false
action_delay: 25

libraries:
  - name: "Movies"
    radarr: "Radarr"
    action_mode: "delete"
    add_list_exclusion_on_delete: True
    last_watched_threshold: 30
    watch_status: watched
    apply_last_watch_threshold_to_collections: true
    added_at_threshold: 90
    max_actions_per_run: 10
    disk_size_threshold:
      - path: "${MOVIES_PATH}"
        threshold: 1TB
      - path: "${DOWNLOADS_PATH}/complete/movies-radarr"
        threshold: 1TB
    sort:
      field: release_year
      order: asc
    exclude:
      titles: []
      tags: ["favorite"]
      genres: []
      collections: []
      release_years: 5

  - name: "TV Shows"
    action_mode: delete
    last_watched_threshold: 365
    added_at_threshold: 180
    apply_last_watch_threshold_to_collections: false
    max_actions_per_run: 10
    disk_size_threshold:
      - path: "${MOVIES_PATH}"
        threshold: 1TB
      - path: "${DOWNLOADS_PATH}/complete/movies-radarr"
        threshold: 1TB
    sonarr: Sonarr
    series_type: standard
    sort:
      field: seasons
      order: desc
    exclude:
      titles: []
      tags: []
      genres: []
      collections: []
      release_years: 2
EOF
)"
}

generate_recyclarr_config() {
    create_file "$CONFIG_ROOT/recyclarr/recyclarr.yml" "$(cat << EOF
sonarr:
  - base_url: http://sonarr:8989
    api_key: ${SONARR_API_KEY}
    delete_old_custom_formats: true
    replace_existing_custom_formats: true
    quality_definition:
      type: series
      preferred_ratio: 0.5
    quality_profiles:
      - name: HD-1080p
        reset_unmatched_scores: true
        upgrade_until_quality: Bluray-1080p
        min_score: 0
        qualities:
          - name: Bluray-1080p
            score: 200
          - name: WEB 1080p
            score: 180
          - name: HDTV-1080p
            score: 90
    custom_formats:
      - trash_ids: []
        quality_profiles:
          - name: HD-1080p
            score: 100

radarr:
  - base_url: http://radarr:7878
    api_key: ${RADARR_API_KEY}
    delete_old_custom_formats: true
    replace_existing_custom_formats: true
    quality_definition:
      type: movie
      preferred_ratio: 0.5
    quality_profiles:
      - name: HD-1080p
        reset_unmatched_scores: true
        upgrade_until_quality: Bluray-1080p
        min_score: 0
        qualities:
          - name: Bluray-1080p
            score: 200
          - name: WEB 1080p
            score: 180
          - name: HDTV-1080p
            score: 90
    custom_formats:
      - trash_ids: []
        quality_profiles:
          - name: HD-1080p
            score: 100

schedule:
  - name: sync-hourly
    schedule: "0 * * * *"
    custom_formats: true
    quality_profiles: true
    quality_definitions: true
    delete_old_custom_formats: true
EOF
)"
}

generate_bazarr_config() {
    local sonarr_api_key="$1"
    local radarr_api_key="$2"
    local config_file="$CONFIG_ROOT/bazarr/config/config.yaml"

    local existing_bazarr_key
    existing_bazarr_key=$(read_existing_yaml_key "$config_file" "auth" "apikey")
    local bazarr_api_key="${existing_bazarr_key:-$(openssl rand -hex 16)}"

    local flask_secret
    flask_secret=$(openssl rand -hex 16)

    create_dir "$CONFIG_ROOT/bazarr/config"
    create_file "$config_file" "$(cat << EOF
---
auth:
  apikey: ${bazarr_api_key}
  password: ''
  type: null
  username: ''
analytics:
  enabled: true
general:
  adaptive_searching: true
  adaptive_searching_delay: 3w
  adaptive_searching_delta: 1w
  anti_captcha_provider: null
  auto_update: true
  base_url: ''
  branch: master
  chmod: '0640'
  chmod_enabled: false
  days_to_upgrade_subs: 7
  debug: false
  default_und_audio_lang: ''
  default_und_embedded_subtitles_lang: ''
  dont_notify_manual_actions: false
  embedded_subs_show_desired: true
  embedded_subtitles_parser: ffprobe
  enabled_integrations: []
  enabled_providers: []
  flask_secret_key: ${flask_secret}
  hi_extension: hi
  ignore_ass_subs: false
  ignore_pgs_subs: false
  ignore_vobsub_subs: false
  ip: '*'
  language_equals: []
  minimum_score: 90
  minimum_score_movie: 70
  movie_default_enabled: false
  movie_default_profile: ''
  movie_tag_enabled: false
  multithreading: true
  page_size: 25
  parse_embedded_audio_track: false
  path_mappings: []
  path_mappings_movie: []
  port: 6767
  postprocessing_cmd: ''
  postprocessing_threshold: 90
  postprocessing_threshold_movie: 70
  remove_profile_tags: []
  serie_default_enabled: false
  serie_default_profile: ''
  serie_tag_enabled: false
  single_language: false
  skip_hashing: false
  subfolder: current
  subfolder_custom: ''
  subzero_mods: ''
  theme: auto
  upgrade_frequency: 12
  upgrade_manual: true
  upgrade_subs: true
  use_embedded_subs: true
  use_postprocessing: false
  use_postprocessing_threshold: false
  use_postprocessing_threshold_movie: false
  use_radarr: true
  use_scenename: true
  use_sonarr: true
  utf8_encode: true
  wanted_search_frequency: 6
  wanted_search_frequency_movie: 6
radarr:
  apikey: ${radarr_api_key}
  base_url: ''
  defer_search_signalr: false
  excluded_tags: []
  full_update: Daily
  full_update_day: 6
  full_update_hour: 4
  http_timeout: 60
  ip: radarr
  movies_sync: 60
  only_monitored: false
  port: 7878
  ssl: false
  sync_only_monitored_movies: false
  use_ffprobe_cache: true
sonarr:
  apikey: ${sonarr_api_key}
  base_url: ''
  defer_search_signalr: false
  exclude_season_zero: false
  excluded_series_types: []
  excluded_tags: []
  full_update: Daily
  full_update_day: 6
  full_update_hour: 4
  http_timeout: 60
  ip: sonarr
  only_monitored: false
  port: 8989
  series_sync: 60
  ssl: false
  sync_only_monitored_episodes: false
  sync_only_monitored_series: false
  use_ffprobe_cache: true
backup:
  day: 6
  folder: /config/backup
  frequency: Weekly
  hour: 3
  retention: 31
postgresql:
  database: ''
  enabled: false
  host: localhost
  password: ''
  port: 5432
  username: ''
proxy:
  exclude:
  - localhost
  - 127.0.0.1
  password: ''
  port: ''
  type: null
  url: ''
  username: ''
EOF
)"
    printf "%s" "$bazarr_api_key"
}

# Helper function: Determine URL format based on DOMAIN
# Returns direct IP:port URLs for localhost or IP addresses
# Returns Traefik hostname URLs for custom domains
get_service_url() {
    local service_name=$1
    local port=$2
    local domain="${DOMAIN:-localhost}"
    
    # Check if DOMAIN is localhost, an IP address, or contains .nip.io
    if [[ "$domain" == "localhost" ]] || [[ "$domain" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || [[ "$domain" =~ \.nip\.io$ ]]; then
        # Use direct IP:port access
        echo "http://${domain}:${port}"
    else
        # Use Traefik hostname
        echo "http://${service_name}.${domain}"
    fi
}

generate_service_dirs() {
    create_dir "$CONFIG_ROOT/jellyfin/transcode"
    create_dir "$CONFIG_ROOT/jellystat/backup-data"
    create_dir "$CONFIG_ROOT/jellystat-db/data"
    create_dir "$CONFIG_ROOT/dockhand/data"
    create_dir "$CONFIG_ROOT/huntarr"
    create_dir "$CONFIG_ROOT/recommendarr"
    create_dir "$CONFIG_ROOT/boxarr"
    create_dir "$CONFIG_ROOT/profilarr"
    create_dir "$CONFIG_ROOT/wud/store"
    create_dir "$CONFIG_ROOT/traefik/letsencrypt"
    create_dir "$CONFIG_ROOT/bazarr"
    create_dir "$CONFIG_ROOT/seerr"
    create_dir "$CONFIG_ROOT/homepage"
}

generate_homepage_config() {
    create_dir "$CONFIG_ROOT/homepage"

    create_file "$CONFIG_ROOT/homepage/docker.yaml" "$(cat << EOF
my-docker:
  socket: /var/run/docker.sock
EOF
)"

    create_file "$CONFIG_ROOT/homepage/settings.yaml" "$(cat << EOF
title: ArrGo Dashboard
favicon: https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/png/jellyfin.png

background: https://images.unsplash.com/photo-1534796636912-3b95b3ab5986?w=1920&q=80

theme: dark
color: slate

headerStyle: boxed

layout:
  Media:
    style: row
    columns: 1
  Requests:
    style: row
    columns: 1
  Movies & TV:
    style: row
    columns: 3
  Indexers:
    style: row
    columns: 2
  Downloads:
    style: row
    columns: 1
  Monitoring:
    style: row
    columns: 2
  Infrastructure:
    style: row
    columns: 2
  Dashboards:
    style: row
    columns: 1
  Tools:
    style: row
    columns: 4

quicklaunch:
  searchDescriptions: true
  hideInternetSearch: false
  hideVisitURL: false

showStats: true

statusStyle: dot
EOF
)"

    create_file "$CONFIG_ROOT/homepage/bookmarks.yaml" "$(cat << EOF
- Media Links:
    - TMDB:
        href: https://www.themoviedb.org/
        icon: tmdb.png

    - Trakt:
        href: https://trakt.tv/
        icon: trakt.png
EOF
)"

    local jellyfin_url=$(get_service_url "jellyfin" "8096")
    local seerr_url=$(get_service_url "seerr" "5055")
    local radarr_url=$(get_service_url "radarr" "7878")
    local sonarr_url=$(get_service_url "sonarr" "8989")
    local bazarr_url=$(get_service_url "bazarr" "6767")
    local prowlarr_url=$(get_service_url "prowlarr" "9696")
    local jackett_url=$(get_service_url "jackett" "9117")
    local qbittorrent_url=$(get_service_url "qbittorrent" "8080")
    local jellystat_url=$(get_service_url "jellystat" "3003")
    local wud_url=$(get_service_url "wud" "3000")
    local dockhand_url=$(get_service_url "dockhand" "3002")
    local huntarr_url=$(get_service_url "huntarr" "9705")
    local recommendarr_url=$(get_service_url "recommendarr" "3001")

    create_file "$CONFIG_ROOT/homepage/services.yaml" "$(cat << EOF
- Media:
    - Jellyfin:
        icon: jellyfin.png
        href: ${jellyfin_url}
        description: Media Server
        widget:
          type: jellyfin
          url: http://jellyfin:8096
          key: ${HOMEPAGE_VAR_JELLYFIN_API_KEY:-}

- Requests:
    - Seerr:
        icon: overseerr.png
        href: ${seerr_url}
        description: Media Requests
        widget:
          type: overseerr
          url: http://seerr:5055
          key: ${HOMEPAGE_VAR_SEERR_API_KEY:-}

- Movies & TV:
    - Radarr:
        icon: radarr.png
        href: ${radarr_url}
        description: Movie Management
        widget:
          type: radarr
          url: http://radarr:7878
          key: ${HOMEPAGE_VAR_RADARR_API_KEY:-}

    - Sonarr:
        icon: sonarr.png
        href: ${sonarr_url}
        description: TV Series Management
        widget:
          type: sonarr
          url: http://sonarr:8989
          key: ${HOMEPAGE_VAR_SONARR_API_KEY:-}

    - Bazarr:
        icon: bazarr.png
        href: ${bazarr_url}
        description: Subtitles Management
        widget:
          type: bazarr
          url: http://bazarr:6767
          key: ${HOMEPAGE_VAR_BAZARR_API_KEY:-}

- Indexers:
    - Prowlarr:
        icon: prowlarr.png
        href: ${prowlarr_url}
        description: Indexer Manager
        widget:
          type: prowlarr
          url: http://prowlarr:9696
          key: ${HOMEPAGE_VAR_PROWLARR_API_KEY:-}

    - Jackett:
        icon: jackett.png
        href: ${jackett_url}
        description: Indexer Proxy
        widget:
          type: jackett
          url: http://jackett:9117
          key: ${HOMEPAGE_VAR_JACKETT_API_KEY:-}

- Downloads:
    - qBittorrent:
        icon: qbittorrent.png
        href: ${qbittorrent_url}
        description: Torrent Client
        widget:
          type: qbittorrent
          url: http://qbittorrent:8080
          username: admin
          password: adminadmin

- Monitoring:
    - Jellystat:
        icon: jellystat.png
        href: ${jellystat_url}
        description: Jellyfin Statistics
        widget:
          type: jellystat
          url: http://jellystat:3000
          key: ${HOMEPAGE_VAR_JELLYSTAT_API_KEY:-}

    - What's Up Docker:
        icon: whatsupdocker.png
        href: ${wud_url}
        description: Container Update Monitor

- Infrastructure:
    - Traefik:
        icon: traefik.png
        href: http://127.0.0.1:8082
        description: Reverse Proxy
        widget:
          type: traefik
          url: http://traefik:8080

    - Dockhand:
        icon: portainer.png
        href: ${dockhand_url}
        description: Container Management

- Dashboards:
    - Huntarr:
        icon: huntarr.png
        href: ${huntarr_url}
        description: Media Wishlist & Hunt Manager

    - Recommendarr:
        icon: recommendarr.png
        href: ${recommendarr_url}
        description: Media Recommendations
EOF
)"
}

# Seerr configuration is now managed manually through the UI
# This function is disabled to prevent conflicts with user-configured settings
# The config directory will still be created for volume mounting
generate_seerr_config() {
    log "YELLOW" "Skipping Seerr configuration generation - configure manually via UI at http://YOUR_IP:5055"
    create_dir "$CONFIG_ROOT/seerr"
}

if [ ! -f .env ]; then
    log "RED" "Environment file .env not found!"
    exit 1
fi

source .env

log "BLUE" "Creating required directories..."
create_dir "$CONFIG_ROOT"
create_dir "$STORAGE_ROOT"

log "BLUE" "Generating configurations..."

log "BLUE" "Generating Prowlarr configuration..."
PROWLARR_API_KEY=$(generate_prowlarr_config)

log "BLUE" "Generating Jackett configuration..."
JACKETT_API_KEY=$(generate_jackett_config)

log "BLUE" "Generating Sonarr configuration..."
SONARR_API_KEY=$(generate_sonarr_config)
generate_sonarr_indexers "$PROWLARR_API_KEY" "$JACKETT_API_KEY"

log "BLUE" "Generating Radarr configuration..."
RADARR_API_KEY=$(generate_radarr_config)
generate_radarr_indexers "$PROWLARR_API_KEY" "$JACKETT_API_KEY"

log "BLUE" "Generating qBittorrent configuration..."
generate_qbittorrent_config "$PROWLARR_API_KEY" "$JACKETT_API_KEY"

log "BLUE" "Generating Traefik configuration..."
generate_traefik_config

log "BLUE" "Updating API keys in .env file..."
update_env_var "SONARR_API_KEY" "$SONARR_API_KEY"
update_env_var "RADARR_API_KEY" "$RADARR_API_KEY"
update_env_var "PROWLARR_API_KEY" "$PROWLARR_API_KEY"
update_env_var "JACKETT_API_KEY" "$JACKETT_API_KEY"

source .env

log "BLUE" "Generating other configurations..."
generate_recyclarr_config
generate_seerr_config "$RADARR_API_KEY" "$SONARR_API_KEY"

log "BLUE" "Generating Bazarr configuration..."
BAZARR_API_KEY=$(generate_bazarr_config "$SONARR_API_KEY" "$RADARR_API_KEY")
update_env_var "BAZARR_API_KEY" "$BAZARR_API_KEY"

log "BLUE" "Generating Homepage configuration..."
log "BLUE" "Writing API keys to .env for homepage..."
update_env_var "HOMEPAGE_VAR_JELLYFIN_API_KEY" "${JELLYFIN_API_KEY:-}"
update_env_var "HOMEPAGE_VAR_SEERR_API_KEY" "${SEERR_API_KEY:-}"
update_env_var "HOMEPAGE_VAR_RADARR_API_KEY" "$RADARR_API_KEY"
update_env_var "HOMEPAGE_VAR_SONARR_API_KEY" "$SONARR_API_KEY"
update_env_var "HOMEPAGE_VAR_BAZARR_API_KEY" "$BAZARR_API_KEY"
update_env_var "HOMEPAGE_VAR_PROWLARR_API_KEY" "$PROWLARR_API_KEY"
update_env_var "HOMEPAGE_VAR_JACKETT_API_KEY" "$JACKETT_API_KEY"
update_env_var "HOMEPAGE_VAR_JELLYSTAT_API_KEY" "${JELLYSTAT_JWT_SECRET:-}"

source .env

generate_homepage_config

generate_service_dirs
# Sync API keys into pre-filled databases and config files.
# This ensures integrations work out-of-the-box whether using --defaults or standard install.
log "BLUE" "Syncing API keys into service databases and configs..."
sync_prowlarr_db_keys "$RADARR_API_KEY" "$SONARR_API_KEY"
sync_arr_db_indexer_keys "radarr" "$PROWLARR_API_KEY"
sync_arr_db_indexer_keys "sonarr" "$PROWLARR_API_KEY"
sync_seerr_config_keys "$RADARR_API_KEY" "$SONARR_API_KEY"

log "GREEN" "Configuration generation complete!"
log "BLUE" "Prowlarr API Key: $PROWLARR_API_KEY"
log "BLUE" "Jackett API Key: $JACKETT_API_KEY"
log "BLUE" "Sonarr API Key: $SONARR_API_KEY"
log "BLUE" "Radarr API Key: $RADARR_API_KEY"
log "BLUE" "Bazarr API Key: $BAZARR_API_KEY"
