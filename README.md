*This project has been created as part of the 42 curriculum by yuotsubo.*

# Inception

## Description

Inception is a system administration project that sets up a small web infrastructure using Docker Compose inside a Virtual Machine. The goal is to learn containerization by building and orchestrating multiple Docker services from scratch, without relying on pre-built images.

The infrastructure consists of three services:

- **NGINX** — Reverse proxy and TLS termination (port 443, TLSv1.2/TLSv1.3)
- **WordPress + php-fpm** — Content management system
- **MariaDB** — Relational database for WordPress

Each service runs in its own container, built from a custom Dockerfile based on Debian Bookworm (penultimate stable). The containers communicate through a dedicated Docker bridge network, and persistent data is stored using Docker named volumes mapped to the host filesystem.

## Project Description

### Use of Docker

Docker is used to isolate each service into its own container, ensuring that each component has only the dependencies it needs. Instead of pulling pre-built images from Docker Hub, each Dockerfile installs and configures the service manually from the base Debian image. Docker Compose orchestrates the multi-container setup, managing networks, volumes, secrets, and service dependencies.

The project sources are organized as follows:

| Directory | Purpose |
|---|---|
| `srcs/requirements/nginx/` | NGINX Dockerfile, TLS config, entrypoint |
| `srcs/requirements/wordpress/` | WordPress + php-fpm Dockerfile, pool config, entrypoint |
| `srcs/requirements/mariadb/` | MariaDB Dockerfile, server config, entrypoint |
| `srcs/docker-compose.yml` | Service orchestration |
| `srcs/.env.example` | Environment variables template (copy to `.env`) |
| `secrets/*.example` | Docker secrets templates (copy and edit) |

### Design Choices

- **Debian Bookworm** was chosen over Alpine for broader package availability and familiarity.
- **wp-cli** automates WordPress installation and user creation, removing the need for manual setup through the web UI.
- **Entrypoint scripts** handle initialization (database setup, WordPress download) on first run and skip it on subsequent starts, making the containers idempotent.
- Each entrypoint uses `exec` to replace the shell process with the main service daemon, ensuring proper PID 1 signal handling.

### Virtual Machines vs Docker

| Aspect | Virtual Machine | Docker Container |
|---|---|---|
| Isolation | Full OS with its own kernel | Shares host kernel, isolated via namespaces |
| Resource usage | Heavy (GBs of RAM per VM) | Lightweight (MBs, shares host resources) |
| Startup time | Minutes | Seconds |
| Portability | Requires hypervisor | Runs anywhere Docker is installed |
| Use case | Full OS isolation, different kernels | Application isolation, microservices |

VMs provide stronger isolation but consume more resources. Docker containers are ideal for running services that share the same OS kernel.

### Secrets vs Environment Variables

| Aspect | Environment Variables | Docker Secrets |
|---|---|---|
| Storage | Visible in `docker inspect`, process env | Mounted as files in `/run/secrets/`, tmpfs |
| Security | Can leak via logs, debug output, child processes | Only accessible inside the container filesystem |
| Access control | Available to all processes | Can be restricted per service |
| Use case | Non-sensitive configuration (domain, usernames) | Passwords, API keys, credentials |

This project uses environment variables for non-sensitive values (database name, usernames, domain) and Docker secrets for all passwords.

### Docker Network vs Host Network

| Aspect | Docker Bridge Network | Host Network |
|---|---|---|
| Isolation | Containers have their own network namespace | Container shares host network stack |
| DNS | Automatic service name resolution | No automatic DNS between containers |
| Port conflicts | No conflicts between containers | Containers compete for host ports |
| Security | Only explicitly published ports are accessible | All container ports are exposed |

This project uses a bridge network (`inception`). Host network mode is forbidden by the project requirements because it breaks container isolation.

### Docker Volumes vs Bind Mounts

| Aspect | Docker Named Volumes | Bind Mounts |
|---|---|---|
| Management | Managed by Docker (`docker volume ls`) | Not tracked by Docker |
| Portability | Referenced by name, location abstracted | Depends on absolute host path |
| Permissions | Docker handles permissions | Host filesystem permissions apply directly |
| Backup | `docker volume inspect` to find data | Must know the host path |

This project uses named volumes with `driver_opts` to satisfy two requirements simultaneously: Docker manages them as named volumes, while the data is physically stored in `/home/yuotsubo/data/` on the host.

## Instructions

### Prerequisites

- A Virtual Machine running Linux (Debian/Ubuntu recommended)
- Docker Engine and Docker Compose V2 installed
- `make` installed
- Root or sudo access (for port 443 and `/etc/hosts`)

### Setup

1. Clone the repository:

```bash
git clone <repository-url>
cd Inception
```

2. Copy the environment template and edit as needed:

```bash
cp srcs/.env.example srcs/.env
```

3. Create secrets files from examples and set your own passwords:

```bash
cp secrets/db_root_password.txt.example secrets/db_root_password.txt
cp secrets/db_password.txt.example secrets/db_password.txt
cp secrets/credentials.txt.example secrets/credentials.txt
```

4. Add the domain name to `/etc/hosts`:

```bash
sudo sh -c 'echo "127.0.0.1 yuotsubo.42.fr" >> /etc/hosts'
```

5. Build and start:

```bash
make
```

6. Access the site at `https://yuotsubo.42.fr`.

### Makefile Targets

| Command | Description |
|---|---|
| `make` | Create data dirs, build images, start containers |
| `make down` | Stop and remove containers |
| `make clean` | Stop containers, remove volumes and data |
| `make fclean` | Full cleanup including Docker cache |
| `make re` | Full cleanup and rebuild |
| `make logs` | Follow container logs in real time |

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Specification](https://docs.docker.com/compose/compose-file/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress CLI Handbook](https://make.wordpress.org/cli/handbook/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [Debian Releases](https://www.debian.org/releases/)
- [OpenSSL Manual](https://www.openssl.org/docs/)

### Use of AI

AI (Claude) was used as a learning assistant throughout this project for:

- **Architecture guidance** — Understanding how NGINX, php-fpm, and MariaDB communicate and choosing appropriate configuration options.
- **Dockerfile authoring** — Writing Dockerfiles and entrypoint scripts, with explanations of each directive and why it is needed.
- **Debugging** — Diagnosing container startup failures, database connection issues, and TLS configuration problems.
- **Documentation** — Generating this README, USER_DOC.md, and DEV_DOC.md.

All code was reviewed and understood before inclusion. AI was not used to blindly generate the final solution but rather to support the learning process.
