## ADDED Requirements

### Requirement: Traefik v3 Compatibility Mode

The Traefik configuration SHALL support v2 syntax compatibility during migration.

#### Scenario: v2 compatibility enabled
- **WHEN** Traefik v3 is deployed
- **THEN** `core.defaultRuleSyntax: v2` SHALL be set in static configuration
- **AND** existing v2-style labels SHALL continue to function

### Requirement: Traefik v3 Dashboard Access

The Traefik dashboard SHALL be accessible through the configured domain.

#### Scenario: Dashboard accessible via subdomain
- **WHEN** user navigates to `traefik.${DOMAIN}`
- **THEN** the Traefik dashboard SHALL be displayed
- **AND** API endpoints SHALL be accessible

## MODIFIED Requirements

### Requirement: Traefik Image Version

The stack SHALL use Traefik v3.x as the reverse proxy.

#### Scenario: Traefik v3 deployed
- **WHEN** docker-compose is deployed
- **THEN** Traefik image SHALL be v3.x
- **AND** Docker provider SHALL be configured
- **AND** web entrypoint SHALL listen on port 80

#### Scenario: Docker socket mounted
- **WHEN** Traefik container starts
- **THEN** Docker socket SHALL be mounted read-only
- **AND** Traefik SHALL discover containers automatically

### Requirement: Service Routing Labels

Services SHALL be routed through Traefik using Docker labels.

#### Scenario: Service route configured
- **WHEN** a service has traefik.enable=true label
- **THEN** Traefik SHALL create a router for the service
- **AND** the service SHALL be accessible at `{service}.${DOMAIN}`

#### Scenario: Load balancer port configured
- **WHEN** a service has traefik.http.services.{name}.loadbalancer.server.port label
- **THEN** Traefik SHALL route traffic to the specified port
