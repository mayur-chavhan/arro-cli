#!/bin/bash
# File: reset.sh

# Create logs directory before anything else so the error trap can write to it
mkdir -p logs

# Enable error handling
set -euo pipefail
trap 'log "RED" "Error on line $LINENO: Command failed with exit code $?"' ERR

# Source environment variables
source .env

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    local level=$1
    shift
    local msg="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${!level}[${level}]${NC} ${timestamp} - $msg" | tee -a logs/reset.log
}

confirm_reset() {
    log "RED" "WARNING: This will delete all configuration data!"
    log "YELLOW" "Media files in STORAGE_ROOT will not be touched."
    read -p "Are you sure you want to continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "BLUE" "Operation cancelled."
        exit 0
    fi
}

confirm_purge_volumes() {
    log "YELLOW" "Do you also want to remove bind-mount data directories (jellystat-db, jellystat, wud/store, traefik/letsencrypt, dockhand/data)?"
    log "YELLOW" "This will permanently delete all database and persistent container data stored under ${CONFIG_ROOT}."
    read -p "Remove bind-mount data? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        PURGE_VOLUMES=true
    else
        PURGE_VOLUMES=false
    fi
}

confirm_reset
confirm_purge_volumes

log "BLUE" "Stopping all containers..."
if [[ "$PURGE_VOLUMES" == "true" ]]; then
    docker compose down --remove-orphans --volumes
else
    docker compose down --remove-orphans
fi

log "BLUE" "Removing docker network..."
docker network rm media_network 2>/dev/null || true

log "BLUE" "Creating backup of current configuration..."
backup_date=$(date +%Y%m%d_%H%M%S)
mkdir -p backups
tar -czf "backups/config_backup_${backup_date}.tar.gz" "$CONFIG_ROOT" .env 2>/dev/null || true

log "BLUE" "Removing configuration directories..."
rm -rf "${CONFIG_ROOT:?}"/*

log "BLUE" "Creating fresh directory structure..."
./init.sh

log "GREEN" "Reset complete!"
log "BLUE" "Your original configuration has been backed up to: backups/config_backup_${backup_date}.tar.gz"
log "BLUE" "Run './arrgo.sh start' to start fresh"