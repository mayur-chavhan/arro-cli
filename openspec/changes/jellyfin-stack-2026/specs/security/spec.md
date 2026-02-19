## ADDED Requirements

### Requirement: Docker Socket Security
The system SHALL restrict Docker socket access through a proxy layer.

#### Scenario: Docker socket is not directly mounted
- **WHEN** a service needs Docker API access
- **THEN** the service SHALL connect to Docker Socket Proxy
- **AND** the service SHALL NOT mount `/var/run/docker.sock` directly

#### Scenario: API access is scoped
- **WHEN** Docker Socket Proxy is configured
- **THEN** only allowed API endpoints SHALL be accessible
- **AND** dangerous operations SHALL be blocked

### Requirement: Minimal Socket Permissions
The system SHALL grant minimal Docker API permissions to each service.

#### Scenario: Traefik socket permissions
- **WHEN** Traefik connects to Docker socket proxy
- **THEN** Traefik SHALL only access containers, networks, and events APIs
- **AND** Traefik SHALL NOT access volumes or exec APIs

#### Scenario: WUD socket permissions
- **WHEN** WUD connects to Docker socket proxy
- **THEN** WUD SHALL only access containers and images APIs
- **AND** WUD SHALL NOT access networks or volumes APIs

#### Scenario: Dockhand socket permissions
- **WHEN** Dockhand connects to Docker socket proxy
- **THEN** Dockhand SHALL access containers, images, networks, volumes, and exec APIs
- **AND** Dockhand SHALL have POST access for management operations

### Requirement: Cloudflare Tunnel Security
The system SHALL use Cloudflare Tunnel token-based authentication.

#### Scenario: Tunnel token is secret
- **WHEN** Cloudflare Tunnel is configured
- **THEN** TUNNEL_TOKEN SHALL be stored in .env file
- **AND** TUNNEL_TOKEN SHALL NOT be committed to version control

#### Scenario: Tunnel runs in restricted network
- **WHEN** Cloudflare Tunnel service runs
- **THEN** tunnel SHALL only connect to Cloudflare edge servers
- **AND** tunnel SHALL NOT accept inbound connections
