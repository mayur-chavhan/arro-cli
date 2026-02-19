## ADDED Requirements

### Requirement: Docker Container Management
The system SHALL provide Dockhand as the primary Docker container management platform.

#### Scenario: Dockhand service is available
- **WHEN** the stack is deployed
- **THEN** Dockhand service SHALL be accessible via Traefik at `dockhand.${DOMAIN}`
- **AND** Dockhand SHALL provide web UI for container management

#### Scenario: Dockhand uses Docker Socket Proxy
- **WHEN** Dockhand connects to Docker API
- **THEN** Dockhand SHALL connect via Docker Socket Proxy
- **AND** Dockhand SHALL NOT have direct access to Docker socket

#### Scenario: Dockhand supports OIDC/SSO
- **WHEN** OIDC is configured
- **THEN** Dockhand SHALL allow authentication via OIDC provider
- **AND** Dockhand SHALL support MFA/TOTP for local accounts

### Requirement: Docker Socket Proxy
The system SHALL provide a Docker Socket Proxy for secure Docker API access.

#### Scenario: Socket proxy restricts API access
- **WHEN** a service connects to Docker socket proxy
- **THEN** the proxy SHALL only allow configured API endpoints
- **AND** the proxy SHALL reject unauthorized API calls

#### Scenario: Socket proxy supports multiple services
- **WHEN** multiple services need Docker API access
- **THEN** socket proxy SHALL provide access to Traefik, Dockhand, and WUD
- **AND** each service SHALL only access permitted endpoints

### Requirement: Cloudflare Tunnel Support
The system SHALL support optional Cloudflare Tunnel for secure external access.

#### Scenario: Cloudflare Tunnel is optional
- **WHEN** TUNNEL_TOKEN environment variable is NOT set
- **THEN** Cloudflare Tunnel service SHALL NOT start
- **AND** the stack SHALL function normally without tunnel

#### Scenario: Cloudflare Tunnel is enabled
- **WHEN** TUNNEL_TOKEN environment variable IS set
- **THEN** Cloudflare Tunnel SHALL connect to Cloudflare edge
- **AND** services SHALL be accessible via configured tunnel routes

#### Scenario: Tunnel does not require port forwarding
- **WHEN** Cloudflare Tunnel is active
- **THEN** no inbound ports SHALL be required on the host
- **AND** all traffic SHALL route through Cloudflare

## REMOVED Requirements

### Requirement: Portainer Container Management
**Reason**: Replaced by Dockhand with better free-tier features
**Migration**: Users must recreate stacks in Dockhand; Portainer configs not migrated
