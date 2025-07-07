# n8n Self-Hosting with Docker

Installing and running [n8n](https://n8n.io/) in Docker, with optional PostgreSQL integration, timezone configuration, and update procedures.

## Prerequisites

- **Docker Desktop** (macOS / Windows) or  
- **Docker Engine** + **Docker Compose** (Linux)  

## Quick Start (SQLite)

1. **Create a Docker volume**  
   ```bash
   docker volume create n8n_data
   ````

2. **Run n8n container**

   ```bash
   docker run -it --rm \
     --name n8n \
     -p 5678:5678 \
     -v n8n_data:/home/node/.n8n \
     docker.n8n.io/n8nio/n8n
   ```
   
3. **Access UI**
   Open your browser at:

   ```
   http://localhost:5678
   ```

This uses the built-in SQLite database and persists all data (including your encryption key and workflows) in the `n8n_data` volume.

## Using PostgreSQL

By default, n8n uses SQLite. To switch to PostgreSQL:

1. **Create the persistent volume**

   ```bash
   docker volume create n8n_data
   ```
2. **Run with PostgreSQL env vars**

   ```bash
   docker run -it --rm \
     --name n8n \
     -p 5678:5678 \
     -e DB_TYPE=postgresdb \
     -e DB_POSTGRESDB_DATABASE=<POSTGRES_DATABASE> \
     -e DB_POSTGRESDB_HOST=<POSTGRES_HOST> \
     -e DB_POSTGRESDB_PORT=<POSTGRES_PORT> \
     -e DB_POSTGRESDB_USER=<POSTGRES_USER> \
     -e DB_POSTGRESDB_PASSWORD=<POSTGRES_PASSWORD> \
     -v n8n_data:/home/node/.n8n \
     docker.n8n.io/n8nio/n8n
   ```

> **Important**: Always persist the `/home/node/.n8n` folder to retain the credentials’ encryption key. If lost, previously saved credentials become inaccessible.

## Timezone Configuration

Define the timezone for scheduling nodes and system scripts:

```bash
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -e GENERIC_TIMEZONE="Europe/Berlin" \
  -e TZ="Europe/Berlin" \
  -v n8n_data:/home/node/.n8n \
  docker.n8n.io/n8nio/n8n
```

* `GENERIC_TIMEZONE`: Used by schedule triggers, auto-timestamps, etc.
* `TZ`: System timezone for commands like `date`.

## Local Development: n8n with Tunnel

To allow external services (e.g., GitHub webhooks) to reach local n8n, run n8n in tunnel mode. n8n’s tunnel service will forward public requests to the local instance.

1. **Create the Docker volume** (haven’t already)

   ```bash
   docker volume create n8n_data
   ```

2. **Start n8n with tunnel**

   ```bash
   docker run -it --rm \
     --name n8n \
     -p 5678:5678 \
     -v n8n_data:/home/node/.n8n \
     docker.n8n.io/n8nio/n8n \
     start --tunnel
   ```

3. **Copy the public tunnel URL** from the container logs and configure the external service’s webhook endpoint to use it.

## Updating n8n

### Using Docker CLI

1. **Pull latest image**

   ```bash
   # Stable
   docker pull docker.n8n.io/n8nio/n8n
   # Specific version
   docker pull docker.n8n.io/n8nio/n8n:1.81.0
   # Beta (“next”)
   docker pull docker.n8n.io/n8nio/n8n:next
   ```
   
2. **Restart container**

   ```bash
   docker ps -a                 # find CONTAINER ID
   docker stop <container_id>
   docker rm   <container_id>
   # restart with your previous run options:
   docker run --name n8n [options] -d docker.n8n.io/n8nio/n8n
   ```

### Using Docker Desktop (GUI)

* Go to **Images** → Right-click on `docker.n8n.io/n8nio/n8n` → **Pull**.

## Updating with Docker Compose

If you deployed via `docker-compose.yml`:

```bash
# In your compose directory
docker compose pull
docker compose down
docker compose up -d
```

## Helper Shell Scripts

1. **Download or copy** each of the following into your project directory:

   * `start-n8n-sqlite.sh`
   * `start-n8n-postgres.sh`
   * `start-n8n-with-timezone.sh`
   * `update-n8n-cli.sh`
   * `update-n8n-compose.sh`

2. **Make them executable**:

   ```bash
   chmod +x start-n8n-*.sh update-n8n-*.sh
   ```

3. **Edit configuration**:

   * For the PostgreSQL script (`start-n8n-postgres.sh`), fill in your database host, port, name, user, password, and schema at the top of the script.
   * For the Compose update script (`update-n8n-compose.sh`), set `COMPOSE_DIR` to the path where your `docker-compose.yml` lives.

4. **Run the scripts**:

   * **Quick start with SQLite**:

     ```bash
     ./start-n8n-sqlite.sh
     ```
   * **Start with PostgreSQL**:

     ```bash
     ./start-n8n-postgres.sh
     ```
   * **Start with custom timezone**:

     ```bash
     ./start-n8n-with-timezone.sh
     ```
   * **Update via Docker CLI**:

     ```bash
     ./update-n8n-cli.sh
     ```
   * **Update via Docker Compose**:

     ```bash
     ./update-n8n-compose.sh
     ```

## Production Deployment with Docker Compose

`docker-compose.prod.yml` for a production‑grade setup.

```yaml
version: "3.8"

services:
  n8n:
    image: docker.n8n.io/n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_USER=n8n
      - DB_POSTGRESDB_PASSWORD=supersecret
      - GENERIC_TIMEZONE=UTC
      - TZ=UTC
      - EXECUTIONS_PROCESS=queue
      - QUEUE_BULL_REDIS_HOST=redis
      - METRICS_ENABLED=true
    volumes:
      - n8n_data:/home/node/.n8n
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:5678/healthz || exit 1"]
      interval: 30s
      timeout: 5s
      retries: 3
    labels:
      - "traefik.http.routers.n8n.rule=Host(`n8n.example.com`)"
      - "traefik.http.routers.n8n.tls=true"
      - "traefik.http.routers.n8n.tls.certresolver=le"

  redis:
    image: redis:6-alpine
    restart: unless-stopped

  postgres:
    image: postgres:15-alpine
    restart: unless-stopped
    environment:
      - POSTGRES_DB=n8n
      - POSTGRES_USER=n8n
      - POSTGRES_PASSWORD=supersecret
    volumes:
      - pg_data:/var/lib/postgresql/data

  proxy:
    image: traefik:latest
    command:
      - "--providers.docker=true"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.le.acme.tlschallenge=true"
      - "--certificatesresolvers.le.acme.email=you@example.com"
      - "--certificatesresolvers.le.acme.storage=/letsencrypt/acme.json"
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - traefik_letsencrypt:/letsencrypt

volumes:
  n8n_data:
  pg_data:
  traefik_letsencrypt:
```

### Bringing up Production

```bash
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```

1. **Pull images**:

   ```bash
   docker-compose -f docker-compose.prod.yml pull
   ```
2. **Start services** in detached mode:

   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```
3. **Verify**

   * Check health:

     ```bash
     docker ps
     docker-compose -f docker-compose.prod.yml ps
     ```
   * Visit `https://n8n.example.com` (or your hostname) to confirm the UI is up.





