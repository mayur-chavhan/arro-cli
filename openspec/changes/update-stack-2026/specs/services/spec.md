## MODIFIED Requirements

### Requirement: Sonarr Service

The stack SHALL provide Sonarr v4 for TV series management.

#### Scenario: Sonarr deployed with dark theme
- **WHEN** Sonarr container starts
- **THEN** Sonarr v4 SHALL be running
- **AND** dark theme SHALL be applied via theme.park mod
- **AND** Sonarr SHALL be accessible at `sonarr.${DOMAIN}:8989`

### Requirement: Radarr Service

The stack SHALL provide Radarr v5 for movie management.

#### Scenario: Radarr deployed with dark theme
- **WHEN** Radarr container starts
- **THEN** Radarr v5 SHALL be running
- **AND** dark theme SHALL be applied via theme.park mod
- **AND** Radarr SHALL be accessible at `radarr.${DOMAIN}:7878`

### Requirement: Readarr Service

The stack SHALL provide Readarr for book management using the hotio image.

#### Scenario: Readarr deployed with hotio image
- **WHEN** Readarr container starts
- **THEN** hotio/readarr image SHALL be used
- **AND** dark theme SHALL be applied via theme.park mod
- **AND** Readarr SHALL be accessible at `readarr.${DOMAIN}:8787`

### Requirement: Lidarr Service

The stack SHALL provide Lidarr for music management.

#### Scenario: Lidarr deployed with dark theme
- **WHEN** Lidarr container starts
- **THEN** Lidarr SHALL be running on current version
- **AND** dark theme SHALL be applied via theme.park mod
- **AND** Lidarr SHALL be accessible at `lidarr.${DOMAIN}:8686`

### Requirement: Prowlarr Service

The stack SHALL provide Prowlarr for indexer management.

#### Scenario: Prowlarr deployed with dark theme
- **WHEN** Prowlarr container starts
- **THEN** Prowlarr SHALL be running on current version
- **AND** dark theme SHALL be applied via theme.park mod
- **AND** Prowlarr SHALL be accessible at `prowlarr.${DOMAIN}:9696`

### Requirement: Bazarr Service

The stack SHALL provide Bazarr for subtitle management.

#### Scenario: Bazarr deployed with dark theme
- **WHEN** Bazarr container starts
- **THEN** Bazarr SHALL be running on current version
- **AND** dark theme SHALL be applied via theme.park mod
- **AND** Bazarr SHALL be accessible at `bazarr.${DOMAIN}:6767`

### Requirement: qBittorrent Service

The stack SHALL provide qBittorrent for torrent management with dark theme.

#### Scenario: qBittorrent deployed with dark theme
- **WHEN** qBittorrent container starts
- **THEN** qBittorrent SHALL be running on current version
- **AND** dark theme SHALL be applied via theme.park mod
- **AND** WebUI SHALL be accessible at `qbittorrent.${DOMAIN}:8080`
- **AND** torrent ports SHALL be 6881 TCP/UDP

### Requirement: Seerr Service

The stack SHALL provide Seerr for media request management.

#### Scenario: Seerr deployed replacing Overseerr
- **WHEN** Seerr container starts
- **THEN** Seerr SHALL be running (unified Overseerr/Jellyseerr codebase)
- **AND** dark theme SHALL be applied via theme.park mod
- **AND** Seerr SHALL be accessible at `seerr.${DOMAIN}:5055`
- **AND** existing Overseerr data SHALL be migrated

### Requirement: Plex Service

The stack SHALL provide Plex Media Server.

#### Scenario: Plex deployed
- **WHEN** Plex container starts
- **THEN** Plex SHALL be running on current version
- **AND** Plex SHALL be accessible at `plex.${DOMAIN}:32400`
- **AND** PLEX_CLAIM token SHALL be configurable via environment

### Requirement: Homarr Service

The stack SHALL provide Homarr as the dashboard.

#### Scenario: Homarr deployed
- **WHEN** Homarr container starts
- **THEN** Homarr SHALL be running on current version
- **AND** Homarr SHALL be accessible at `homarr.${DOMAIN}:7575`
- **AND** built-in dark mode SHALL be available in settings
