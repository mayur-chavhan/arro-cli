```

           |    |    |
          )_)  )_)  )_)
         )___))___))___)
      )____)____)_____)
   _____|____|____|____\\___    
~~~\___________________________/~~~  
    ~~~    ~    ~~~    ~   ~~~     ArrGo
    
```
<div align="center">
<h2>ArrGo Media Server Stack</h2>

[![Docker](https://img.shields.io/badge/Docker-Required-blue.svg)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)]()
[![Jellyfin](https://img.shields.io/badge/Jellyfin-Media_Server-purple.svg)](https://jellyfin.org/)
[![Contributions Welcome](https://img.shields.io/badge/Contributions-Welcome-brightgreen.svg)]()

A comprehensive Docker-based media server stack with automated management, monitoring, and organization.

**v3.0.0 (2026)**: Now powered by Jellyfin with enhanced security (Docker Socket Proxy), advanced monitoring (Jellystat, Huntarr, Recommendarr), and optional Cloudflare Tunnel support.

**Disclaimer**: This project is for educational purposes only. It is intended to showcase open-source software concepts and demonstrate server components. Use responsibly and with awareness of any applicable licensing and usage policies.

[Installation](docs/installation.md) •
[Configuration](docs/configuration.md) •
[Services](docs/services.md) •
[Migration Guide](docs/migration.md) •
[Jellyfin Setup](docs/jellyfin-setup.md) •
[Post-Install Setup](docs/post-install.md) •
[Maintenance](docs/maintenance.md) •
[Security](docs/security.md) •
[Troubleshooting](docs/troubleshooting.md)

</div>

## 📋 Quick Start

### What's New in v3.0.0

#### Media Server
- **Jellyfin** - Replaces Plex as the primary media server (free, open-source)

#### Container Management
- **Dockhand** - Replaces Portainer for lightweight container management
- **Docker Socket Proxy** - Secure Docker API access for services

#### Monitoring & Analytics
- **Jellystat** - Jellyfin statistics and playback monitoring
- **Huntarr** - Automated media hunting and wishlist management
- **Recommendarr** - Personalized media recommendations
- **Boxarr** - Collection and box set management
- **Profilarr** - Quality profile management
- **Configarr** - Configuration sync and templates

#### Indexers
- **Jackett** - Added as indexer proxy alongside Prowlarr

#### Security
- **Cloudflare Tunnel** - Optional secure external access (no port forwarding)

#### Removed Services
- **Lidarr** - Removed (Jellyfin supports music natively)
- **Readarr** - Removed (Jellyfin supports books natively)
- **Calibre** - Removed (Jellyfin supports books natively)
- **Portainer** - Replaced by Dockhand
- **Plex** - Replaced by Jellyfin

See the [Migration Guide](docs/migration.md) for upgrading from v2.x.

### Installation

1. Clone the repository

```bash
git clone https://github.com/mayur-chavhan/arro-cli.git
cd arro-cli
```

### Option 1: Standard Installation

2. Set up environment

```bash
cp .env.example .env
nano .env
```

3. Install and start

```bash
./install.sh
```

### Option 2: Quick Installation with Defaults

2. Install with defaults

```bash
./install.sh --defaults
```

3. Start services

```bash
./arrgo.sh start
```

Default Credentials:
- Arr Services (Radarr/Sonarr): admin/admin
- Homarr: admin/Admin123!
- qBittorrent: admin/adminadmin

**Important**: Change these default passwords as soon as possible after installation!

Once the installation and startup are complete, check [Jellyfin Setup](docs/jellyfin-setup.md) for initial configuration and [Services](docs/services.md) for more information about each service.

## 📚 Documentation

- [Installation Guide](docs/installation.md)

  - Prerequisites
  - Installation steps
  - Initial configuration
  - Default installation option

- [Configuration Guide](docs/configuration.md)

  - Environment variables
  - Directory structure
  - Path mappings
  - Dark theming

- [Services Overview](docs/services.md)

  - Available services
  - Default ports
  - Service descriptions

- [Jellyfin Setup Guide](docs/jellyfin-setup.md)

  - Initial configuration
  - Hardware transcoding
  - Library setup
  - Integration with other services

- [Migration Guide](docs/migration.md)

  - Upgrading to v3.0.0
  - Plex to Jellyfin migration
  - Pre-migration checklist
  - Post-migration tasks

- [Post-Installation Setup](docs/post-install.md)

  - Step-by-step service configuration
  - Integration setup
  - Media organization

- [Security Guide](docs/security.md)

  - Default credentials
  - Authentication setup
  - Security best practices

- [Maintenance Guide](docs/maintenance.md)

  - Backup and restore
  - Updates with WUD
  - Health monitoring

- [Troubleshooting Guide](docs/troubleshooting.md)
  - Common issues
  - Logs and diagnostics
  - Solutions

## 🛠 Basic Usage

```bash
./arrgo.sh <command> [options]

Commands:
  start     - Start all services
  stop      - Stop all services
  restart   - Restart all services
  status    - Show service status
  logs      - View service logs
  update    - Update containers
  backup    - Create backup
  check     - Run health check
  help      - Show help
```

## 👥 Contributing

Contributions are welcome!

## 📝 License

This project is licensed under the MIT License.

---

## 🙏 Acknowledgments

This project is inspired by and based on [CaptainArr](https://github.com/bthe0/captainarr) by [bthe0](https://github.com/bthe0). 

ArrGo is a fork that modernizes the stack with:
- Jellyfin as the media server (replacing Plex)
- Enhanced security with Docker Socket Proxy
- Advanced monitoring and automation tools
- Removed deprecated services in favor of Jellyfin native support

---

<div align="center">
Made with ❤️ by [Mayur Chavhan](https://github.com/mayur-chavhan)
</div>