#!/usr/bin/env bash
# start-n8n-sqlite.sh
# Quick-start n8n with SQLite and persistent volume

set -euo pipefail

VOLUME_NAME="n8n_data"
CONTAINER_NAME="n8n"
IMAGE="docker.n8n.io/n8nio/n8n"
HOST_PORT=5678
CONTAINER_PORT=5678

echo "Creating Docker volume '${VOLUME_NAME}' (if not exists)…"
docker volume inspect "${VOLUME_NAME}" >/dev/null 2>&1 || \
  docker volume create "${VOLUME_NAME}"

echo "Starting n8n container (${CONTAINER_NAME})…"
docker run -d \
  --name "${CONTAINER_NAME}" \
  -p "${HOST_PORT}:${CONTAINER_PORT}" \
  -v "${VOLUME_NAME}:/home/node/.n8n" \
  "${IMAGE}"

echo "n8n is up!  Visit http://localhost:${HOST_PORT}"
