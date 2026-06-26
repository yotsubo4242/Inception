# Developer Documentation

## Setting Up the Environment from Scratch

### Prerequisites

- Linux host (or VM) with:
  - Docker Engine (20.10+)
  - Docker Compose V2
  - `make`
  - `sudo` access

### Configuration Files

| File | Purpose | Tracked by Git |
|---|---|---|
| `srcs/.env` | Non-sensitive environment variables (domain, usernames) | No (`.gitignore`) |
| `srcs/.env.example` | Template for `.env` | Yes |
| `secrets/db_root_password.txt` | MariaDB root password | No (`.gitignore`) |
| `secrets/db_root_password.txt.example` | Template for above | Yes |
| `secrets/db_password.txt` | MariaDB user password | No (`.gitignore`) |
| `secrets/db_password.txt.example` | Template for above | Yes |
| `secrets/credentials.txt` | WordPress admin and user passwords (one per line) | No (`.gitignore`) |
| `secrets/credentials.txt.example` | Template for above | Yes |

### Initial Setup

1. Copy the environment template and edit as needed:

```bash
cp srcs/.env.example srcs/.env
```

2. Create secrets files from examples:

```bash
cp secrets/db_root_password.txt.example secrets/db_root_password.txt
cp secrets/db_password.txt.example secrets/db_password.txt
cp secrets/credentials.txt.example secrets/credentials.txt
```

Edit each file to set your own passwords.

3. Add the domain to `/etc/hosts`:

```bash
sudo sh -c 'echo "127.0.0.1 yuotsubo.42.fr" >> /etc/hosts'
```

## Building and Launching

### Makefile Targets

| Target | Command | Description |
|---|---|---|
| `make` (all) | `setup` → `build` → `up` | Full build and start |
| `make setup` | `mkdir -p /home/yuotsubo/data/{mariadb,wordpress}` | Create host data directories |
| `make build` | `docker compose build` | Build all Docker images |
| `make up` | `docker compose up -d` | Start containers in background |
| `make down` | `docker compose down` | Stop and remove containers |
| `make clean` | `docker compose down -v` + remove data dirs | Full data cleanup |
| `make fclean` | `clean` + `docker system prune -af` | Remove all Docker artifacts |
| `make re` | `fclean` + `all` | Full rebuild from scratch |
| `make logs` | `docker compose logs -f` | Stream logs from all services |

### Building Individual Services

```bash
docker compose -f srcs/docker-compose.yml build mariadb
docker compose -f srcs/docker-compose.yml build wordpress
docker compose -f srcs/docker-compose.yml build nginx
```

## Container Management

### Inspecting a Running Container

```bash
docker compose -f srcs/docker-compose.yml exec mariadb bash
docker compose -f srcs/docker-compose.yml exec wordpress bash
docker compose -f srcs/docker-compose.yml exec nginx bash
```

### Viewing Logs for a Single Service

```bash
docker compose -f srcs/docker-compose.yml logs mariadb
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs nginx
```

### Checking MariaDB

```bash
# Connect to MariaDB
docker compose -f srcs/docker-compose.yml exec mariadb mysql -u root -p

# List databases
docker compose -f srcs/docker-compose.yml exec mariadb mysql -u root -p -e "SHOW DATABASES;"

# List WordPress users in the database
docker compose -f srcs/docker-compose.yml exec mariadb mysql -u root -p wordpress -e "SELECT user_login, user_email FROM wp_users;"
```

### Restarting a Single Service

```bash
docker compose -f srcs/docker-compose.yml restart wordpress
```

## Data Storage and Persistence

### Named Volumes

| Volume | Container mount | Host path | Content |
|---|---|---|---|
| `db_data` | `/var/lib/mysql` | `/home/yuotsubo/data/mariadb` | MariaDB database files |
| `wp_data` | `/var/www/html` | `/home/yuotsubo/data/wordpress` | WordPress PHP files, themes, uploads |

The `wp_data` volume is shared between the `wordpress` and `nginx` containers. WordPress writes PHP files and uploads, while NGINX reads them to serve static content and forward PHP requests.

### Inspecting Volumes

```bash
# List volumes
docker volume ls | grep srcs

# Inspect a volume
docker volume inspect srcs_db_data

# Check host data directory
ls -la /home/yuotsubo/data/mariadb/
ls -la /home/yuotsubo/data/wordpress/
```

### Data Lifecycle

- `make down` — Containers are removed but volumes and data persist. Next `make up` reuses existing data.
- `make clean` — Volumes are removed and host data directories are deleted. Next `make` triggers full re-initialization (database creation, WordPress download and install).

### Initialization Behavior

Each entrypoint script is idempotent:

- **MariaDB** — Checks for `/var/lib/mysql/mysql` (engine init) and `/var/lib/mysql/${MYSQL_DATABASE}` (app database). Only runs initialization when these are absent.
- **WordPress** — Checks for `wp-config.php`. Only downloads and installs WordPress when this file is absent.
- **NGINX** — Checks for `/etc/nginx/ssl/nginx.crt`. Only generates an SSL certificate when it is absent.

## Project Structure

```
Inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
│   ├── db_root_password.txt.example
│   ├── db_password.txt.example
│   └── credentials.txt.example
└── srcs/
    ├── .env.example
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── .dockerignore
        │   ├── Dockerfile
        │   ├── conf/50-server.cnf
        │   └── tools/entrypoint.sh
        ├── nginx/
        │   ├── .dockerignore
        │   ├── Dockerfile
        │   ├── conf/default.conf
        │   └── tools/entrypoint.sh
        └── wordpress/
            ├── .dockerignore
            ├── Dockerfile
            ├── conf/www.conf
            └── tools/entrypoint.sh
```
