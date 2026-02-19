## ADDED Requirements

### Requirement: Jellyfin Statistics Dashboard
The system SHALL provide Jellystat for monitoring Jellyfin usage statistics.

#### Scenario: Jellystat service is available
- **WHEN** the stack is deployed
- **THEN** Jellystat service SHALL be accessible at port 3100
- **AND** Jellystat SHALL connect to Jellyfin via API key

#### Scenario: Jellystat uses PostgreSQL database
- **WHEN** Jellystat service starts
- **THEN** Jellystat SHALL connect to PostgreSQL database for data persistence
- **AND** statistics data SHALL persist across container restarts

#### Scenario: Jellystat integrates with Traefik
- **WHEN** Jellystat service is running
- **THEN** Jellystat SHALL be accessible via `jellystat.${DOMAIN}` subdomain

### Requirement: Missing Content Hunter
The system SHALL provide Huntarr for automatically finding and upgrading missing media content.

#### Scenario: Huntarr service is available
- **WHEN** the stack is deployed
- **THEN** Huntarr service SHALL be accessible at port 9705
- **AND** Huntarr SHALL connect to Sonarr and Radarr for content management

#### Scenario: Huntarr processes missing content
- **WHEN** Huntarr runs a hunt cycle
- **THEN** Huntarr SHALL search for missing episodes and movies
- **AND** Huntarr SHALL upgrade content below quality threshold

### Requirement: AI Media Recommendations
The system SHALL provide Recommendarr for AI-powered media recommendations.

#### Scenario: Recommendarr service is available
- **WHEN** the stack is deployed
- **THEN** Recommendarr service SHALL be accessible at port 3000
- **AND** Recommendarr SHALL connect to Sonarr, Radarr, and Jellyfin for library analysis

#### Scenario: Recommendarr generates recommendations
- **WHEN** user requests recommendations
- **THEN** Recommendarr SHALL analyze library content using AI
- **AND** Recommendarr SHALL suggest similar content based on viewing history

### Requirement: Box Office Tracking
The system SHALL provide Boxarr for tracking box office releases with Radarr integration.

#### Scenario: Boxarr service is available
- **WHEN** the stack is deployed
- **THEN** Boxarr service SHALL be accessible at port 5055
- **AND** Boxarr SHALL display current box office top 10

#### Scenario: Boxarr integrates with Radarr
- **WHEN** Boxarr identifies a movie in box office
- **THEN** Boxarr SHALL show if movie exists in Radarr library
- **AND** Boxarr SHALL allow adding missing movies to Radarr

### Requirement: Quality Profile Management
The system SHALL provide Profilarr for managing Sonarr and Radarr quality profiles.

#### Scenario: Profilarr service is available
- **WHEN** the stack is deployed
- **THEN** Profilarr service SHALL be accessible at port 6868
- **AND** Profilarr SHALL connect to Sonarr and Radarr for profile management

#### Scenario: Profilarr syncs profiles
- **WHEN** Profilarr sync is triggered
- **THEN** Profilarr SHALL import quality profiles from community databases
- **AND** Profilarr SHALL apply profiles to connected *arr instances

### Requirement: Configuration Management
The system SHALL provide Configarr for managing *arr application configurations.

#### Scenario: Configarr service is available
- **WHEN** the stack is deployed
- **THEN** Configarr SHALL have access to configuration repositories
- **AND** Configarr SHALL sync configurations to connected *arr instances

### Requirement: Indexer Proxy
The system SHALL provide Jackett as an indexer proxy for broader tracker support.

#### Scenario: Jackett service is available
- **WHEN** the stack is deployed
- **THEN** Jackett service SHALL be accessible at port 9117
- **AND** Jackett SHALL support both public and private trackers

#### Scenario: Jackett supports dark theming
- **WHEN** TP_THEME environment variable is set
- **THEN** Jackett SHALL apply theme.park dark theme

## REMOVED Requirements

### Requirement: Music Management
**Reason**: Lidarr removed to simplify stack focus
**Migration**: AUDIO path preserved for Jellyfin native music library

### Requirement: Book Management
**Reason**: Readarr removed to simplify stack focus
**Migration**: BOOKS path preserved for Jellyfin native book library

### Requirement: Calibre Web
**Reason**: Redundant with Jellyfin book support
**Migration**: Users can access books through Jellyfin
