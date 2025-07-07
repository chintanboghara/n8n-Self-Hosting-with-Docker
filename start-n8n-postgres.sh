#!/usr/bin/env bash
# start-n8n-postgres.sh
# Start n8n using PostgreSQL backend

set -euo pipefail

# === EDIT THESE ===
DB_HOST="your_postgres_host"
DB_PORT="5432"
DB_NAME="your_database"
DB_USER="your_user"
DB_PASSWORD="your_password"
DB_SCHEMA="public"
# ==================

VOLUME_NAME="n8n_data"
CONTAINER_NAME="n8n"
IMAGE="docker.n8n.io/n8nio/n8n"
HOST_PORT=5678
CONTAINER_PORT=5678

echo "Ensuring Docker volume '${VOLUME_NAME}'…"
docker volume inspect "${VOLUME_NAME}" >/dev/null 2>&1 || \
  docker volume create "${VOLUME_NAME}"

echo "Starting n8n container with PostgreSQL…"
docker run -d \
  --name "${CONTAINER_NAME}" \
  -p "${HOST_PORT}:${CONTAINER_PORT}" \
  -e DB_TYPE=postgresdb \
  -e DB_POSTGRESDB_HOST="${DB_HOST}" \
  -e DB_POSTGRESDB_PORT="${DB_PORT}" \
  -e DB_POSTGRESDB_DATABASE="${DB_NAME}" \
  -e DB_POSTGRESDB_USER="${DB_USER}" \
  -e DB_POSTGRESDB_PASSWORD="${DB_PASSWORD}" \
  -e DB_POSTGRESDB_SCHEMA="${DB_SCHEMA}" \
  -v "${VOLUME_NAME}:/home/node/.n8n" \
  "${IMAGE}"

echo "n8n (PostgreSQL) is running at http://localhost:${HOST_PORT}"
