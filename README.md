# n8n Self-Hosting with Docker

This guide explains how to install and run [n8n](https://n8n.io/) using Docker, with options for SQLite or PostgreSQL databases, timezone configuration, local development, updates, and production deployment.

## Prerequisites

- **Docker Desktop** (for macOS or Windows) **OR**  
- **Docker Engine** and **Docker Compose** (for Linux)  

**Before you begin**: Ensure Docker is installed and running. For Docker Desktop users, confirm it’s started in the system tray or dock.

## Quick Start (SQLite)

Get n8n up and running quickly with the default SQLite database—perfect for testing or small-scale use.

1. **Create a Docker volume**  
   This persists your n8n data (e.g., workflows, credentials) outside the container.  
   ```bash
   docker volume create n8n_data
   ```

2. **Run the n8n container**  
   This command runs n8n interactively and removes the container when stopped.  
   ```bash
   docker run -it --rm \
     --name n8n \
     -p 5678:5678 \
     -v n8n_data:/home/node/.n8n \
     docker.n8n.io/n8nio/n8n
   ```

3. **Access the n8n UI**  
   Open your browser and go to:  
   ```
   http://localhost:5678
   ```  
   **Tip**: If port 5678 is in use, modify the port mapping (e.g., `-p 8080:5678`) and access it at `http://localhost:8080`.

> **Note**: The `-it --rm` flags are great for testing (interactive mode with auto-cleanup). For long-running setups, replace them with `-d` to run in detached mode.

## Using PostgreSQL

For better scalability and performance, switch to PostgreSQL instead of SQLite. You’ll need a running PostgreSQL instance.

1. **Create the persistent volume**  
   This is still required to store the encryption key, even with PostgreSQL.  
   ```bash
   docker volume create n8n_data
   ```

2. **Run n8n with PostgreSQL environment variables**  
   Replace the placeholders with your PostgreSQL details (e.g., host, database name, etc.).  
   ```bash
   docker run -it --rm \
     --name n8n \
     -p 5678:5678 \
     -e DB_TYPE=postgresdb \
     -e DB_POSTGRESDB_HOST=<POSTGRES_HOST> \
     -e DB_POSTGRESDB_PORT=<POSTGRES_PORT> \
     -e DB_POSTGRESDB_DATABASE=<POSTGRES_DATABASE> \
     -e DB_POSTGRESDB_USER=<POSTGRES_USER> \
     -e DB_POSTGRESDB_PASSWORD=<POSTGRES_PASSWORD> \
     -v n8n_data:/home/node/.n8n \
     docker.n8n.io/n8nio/n8n
   ```  
   **Example**:  
   ```bash
   -e DB_POSTGRESDB_HOST=localhost \
   -e DB_POSTGRESDB_PORT=5432 \
   -e DB_POSTGRESDB_DATABASE=n8n_db \
   -e DB_POSTGRESDB_USER=n8n_user \
   -e DB_POSTGRESDB_PASSWORD=securepassword
   ```

> **Critical**: Persist the `/home/node/.n8n` folder! It stores the encryption key for credentials. Losing it means previously saved credentials can’t be decrypted.

## Timezone Configuration

Set the timezone to ensure accurate scheduling and timestamps in n8n.

- **`GENERIC_TIMEZONE`**: Used by schedule triggers and timestamps.  
- **`TZ`**: Sets the system timezone for commands like `date`.

**Example** (using "Europe/Berlin"):  
```bash
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -e GENERIC_TIMEZONE="Europe/Berlin" \
  -e TZ="Europe/Berlin" \
  -v n8n_data:/home/node/.n8n \
  docker.n8n.io/n8nio/n8n
```

> **Resource**: See the [TZ database time zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) for valid timezone names.

## Local Development: n8n with Tunnel

Use n8n’s tunnel feature to expose your local instance to external services (e.g., for testing webhooks).

1. **Create the Docker volume** (if not already done)  
   ```bash
   docker volume create n8n_data
   ```

2. **Start n8n with the tunnel**  
   The `--tunnel` flag creates a public URL for your local instance.  
   ```bash
   docker run -it --rm \
     --name n8n \
     -p 5678:5678 \
     -v n8n_data:/home/node/.n8n \
     docker.n8n.io/n8nio/n8n \
     start --tunnel
   ```

3. **Copy the public tunnel URL**  
   Look in the container logs for a URL like `https://<random-string>.loca.lt`. Use this for external webhook configurations.

> **Note**: The tunnel URL changes each time you restart with `--tunnel`. Check the logs if you don’t see it immediately.

## Updating n8n

### Using Docker CLI

1. **Pull the latest image**  
   - Stable version:  
     ```bash
     docker pull docker.n8n.io/n8nio/n8n
     ```  
   - Specific version (e.g., 1.81.0):  
     ```bash
     docker pull docker.n8n.io/n8nio/n8n:1.81.0
     ```  
   - Beta ("next") version:  
     ```bash
     docker pull docker.n8n.io/n8nio/n8n:next
     ```

2. **Restart the container**  
   - Find the container ID:  
     ```bash
     docker ps -a
     ```  
   - Stop and remove the old container:  
     ```bash
     docker stop <container_id>
     docker rm <container_id>
     ```  
   - Restart with your original options (e.g., volumes, ports):  
     ```bash
     docker run --name n8n [your options] -d docker.n8n.io/n8nio/n8n
     ```

> **Tip**: Check your current version with `docker exec -it n8n n8n --version` before updating.

### Using Docker Desktop (GUI)

- Open Docker Desktop, go to **Images**, right-click `docker.n8n.io/n8nio/n8n`, and select **Pull** to update.

## Updating with Docker Compose

For deployments using `docker-compose.yml`:  
```bash
# Navigate to your compose directory
docker compose pull
docker compose down
docker compose up -d
```

> **Best Practice**: Back up your database before updating to avoid potential data loss.

## Helper Shell Scripts

Simplify tasks with these shell scripts. Download or create them in your project directory:

- `start-n8n-sqlite.sh`  
- `start-n8n-postgres.sh`  
- `start-n8n-with-timezone.sh`  
- `update-n8n-cli.sh`  
- `update-n8n-compose.sh`

1. **Make them executable** (one-time step):  
   ```bash
   chmod +x start-n8n-*.sh update-n8n-*.sh
   ```

2. **Edit configurations** (if needed):  
   - For `start-n8n-postgres.sh`, update the database details at the top of the script.  
   - For `update-n8n-compose.sh`, set `COMPOSE_DIR` to your `docker-compose.yml` location.

3. **Run the scripts**:  
   - Quick start with SQLite:  
     ```bash
     ./start-n8n-sqlite.sh
     ```  
   - Start with PostgreSQL:  
     ```bash
     ./start-n8n-postgres.sh
     ```  
   - Start with custom timezone:  
     ```bash
     ./start-n8n-with-timezone.sh
     ```  
   - Update via Docker CLI:  
     ```bash
     ./update-n8n-cli.sh
     ```  
   - Update via Docker Compose:  
     ```bash
     ./update-n8n-compose.sh
     ```

## Production Deployment with Docker Compose

Use the `docker-compose.prod.yml` file below for a production-ready setup with n8n, PostgreSQL, Redis (for queueing), and Traefik (for SSL and reverse proxy).

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

1. **Pull the latest images**  
   ```bash
   docker-compose -f docker-compose.prod.yml pull
   ```

2. **Start services in detached mode**  
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```

3. **Verify the deployment**  
   - Check container status:  
     ```bash
     docker ps
     docker-compose -f docker-compose.prod.yml ps
     ```  
   - Visit `https://n8n.example.com` (replace with your domain) to confirm the UI is running.

> **Important**: Before deploying, update the Traefik labels with your domain (e.g., `n8n.yourdomain.com`) and email for SSL certificates. Ensure your domain points to your server.
