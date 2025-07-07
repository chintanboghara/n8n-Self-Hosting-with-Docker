#!/usr/bin/env bash
# update-n8n-cli.sh
# Pull and restart n8n container using Docker CLI

set -euo pipefail

CONTAINER_NAME="n8n"
IMAGE="docker.n8n.io/n8nio/n8n"
# Optionally override to a specific tag:
# IMAGE="${IMAGE}:1.100.1"
# or
# IMAGE="${IMAGE}:next"

echo "Pulling latest image: ${IMAGE}…"
docker pull "${IMAGE}"

echo "Stopping and removing existing container (${CONTAINER_NAME})…"
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  docker stop "${CONTAINER_NAME}"
  docker rm "${CONTAINER_NAME}"
else
  echo "→ No existing container named ${CONTAINER_NAME}, skipping stop/rm."
fi

echo "Starting new container from ${IMAGE}…"
# Reuse your original run options here:
docker run -d \
  --name "${CONTAINER_NAME}" \
  -p 5678:5678 \
  -v n8n_data:/home/node/.n8n \
  "${IMAGE}"

echo "n8n has been updated and restarted."
