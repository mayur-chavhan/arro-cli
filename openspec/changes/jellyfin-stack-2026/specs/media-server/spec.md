## ADDED Requirements

### Requirement: Jellyfin Media Server
The system SHALL provide Jellyfin as the primary media server for streaming and managing media content.

#### Scenario: Jellyfin service is available
- **WHEN** the stack is deployed
- **THEN** Jellyfin service SHALL be accessible at port 8096
- **AND** Jellyfin SHALL serve movies, TV series, audio, and books from configured paths

#### Scenario: Jellyfin integrates with Traefik
- **WHEN** Jellyfin service is running
- **THEN** Jellyfin SHALL be accessible via `jellyfin.${DOMAIN}` subdomain
- **AND** Traefik SHALL route traffic to Jellyfin port 8096

#### Scenario: Jellyfin supports dark theming
- **WHEN** TP_THEME environment variable is set
- **THEN** Jellyfin SHALL apply theme.park dark theme
- **AND** the theme SHALL match other *arr services

### Requirement: Jellyfin Published Server URL
The system SHALL configure Jellyfin with a published server URL for proper reverse proxy operation.

#### Scenario: Published server URL is configured
- **WHEN** DOMAIN environment variable is set
- **THEN** Jellyfin SHALL use `http://jellyfin.${DOMAIN}` as published server URL
- **AND** media playback SHALL work correctly through reverse proxy

## REMOVED Requirements

### Requirement: Plex Media Server
**Reason**: Replaced by Jellyfin for fully open-source solution
**Migration**: Users must recreate libraries in Jellyfin; no automated migration available
