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
