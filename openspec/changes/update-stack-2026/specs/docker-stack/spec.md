## ADDED Requirements

### Requirement: Dark Theme Support

The stack SHALL provide dark theme support for all compatible services using theme.park Docker mods.

#### Scenario: Dark theme enabled by default
- **WHEN** services are deployed with default configuration
- **THEN** all *arr services, qBittorrent, and Seerr SHALL display with dark theme
- **AND** the default theme SHALL be "nord"

#### Scenario: Custom theme selection
- **WHEN** user sets TP_THEME environment variable to a supported value
- **THEN** all themed services SHALL apply the selected theme
- **AND** supported themes SHALL include: dark, nord, dracula, aquamarine, plex, maroon, space-gray

#### Scenario: Theme disabled
- **WHEN** user removes DOCKER_MODS environment variable from a service
- **THEN** the service SHALL display with default light theme

## MODIFIED Requirements

### Requirement: Docker Compose Configuration

The stack SHALL use a docker-compose.yml file with updated image versions and configuration.

#### Scenario: Service images updated
- **WHEN** docker-compose.yml is deployed
- **THEN** all services SHALL use current stable image versions
- **AND** Sonarr SHALL use v4.x
- **AND** Radarr SHALL use v5.x
- **AND** Readarr SHALL use hotio/readarr image

#### Scenario: Environment variables applied
- **WHEN** services start
- **THEN** PUID and PGID SHALL be set for all services
- **AND** TP_THEME SHALL default to "nord"
- **AND** TZ SHALL default to UTC

### Requirement: Service Port Configuration

The stack SHALL maintain consistent port mappings across updates.

#### Scenario: Standard ports preserved
- **WHEN** services are deployed
- **THEN** port mappings SHALL remain consistent with previous versions
- **AND** Traefik SHALL listen on port 80
- **AND** Plex SHALL listen on port 32400
- **AND** qBittorrent SHALL listen on ports 8080, 6881
- **AND** Seerr SHALL listen on port 5055
