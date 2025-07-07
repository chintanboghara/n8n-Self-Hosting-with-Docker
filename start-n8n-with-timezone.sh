#!/usr/bin/env bash
# start-n8n-with-timezone.sh
# Run n8n with explicit timezone settings

set -euo pipefail

GENERIC_TZ="Europe/Berlin"
SYSTEM_TZ="Europe/Berlin"

VOLUME_NAME="n8n_data"
CONTAINER_NAME="n8n"
IMAGE="docker.n8n.io/n8nio/n8n"
HOST_PORT=5678
CONTAINER_PORT=5678

echo "Ensuring Docker volume '${VOLUME_NAME}'…"
docker volume inspect "${VOLUME_NAME}" >/dev/null 2>&1 || \
  docker volume create "${VOLUME_NAME}"

echo "Starting n8n container with timezone ${GENERIC_TZ}…"
docker run -d \
  --name "${CONTAINER_NAME}" \
  -p "${HOST_PORT}:${CONTAINER_PORT}" \
  -e GENERIC_TIMEZONE="${GENERIC_TZ}" \
  -e TZ="${SYSTEM_TZ}" \
  -v "${VOLUME_NAME}:/home/node/.n8n" \
  "${IMAGE}"

echo "n8n (timezone=${GENERIC_TZ}) is available at http://localhost:${HOST_PORT}"
