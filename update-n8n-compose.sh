#!/usr/bin/env bash
# update-n8n-compose.sh
# Pull & redeploy n8n via Docker Compose

set -euo pipefail

# Path to your compose file directory
COMPOSE_DIR="/path/to/your/compose/dir"

echo "Changing to compose directory: ${COMPOSE_DIR}"
cd "${COMPOSE_DIR}"

echo "Pulling latest images…"
docker compose pull

echo "Bringing down old services…"
docker compose down

echo "Starting up updated services…"
docker compose up -d

echo "n8n (Compose) has been updated and is running."
