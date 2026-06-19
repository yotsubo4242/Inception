# User Documentation

## Overview

This project provides a self-hosted WordPress website with the following services:

| Service | Role |
|---|---|
| **NGINX** | Handles HTTPS connections (port 443) and forwards requests to WordPress |
| **WordPress** | The website application, powered by PHP |
| **MariaDB** | Stores all website data (posts, users, settings) |

## Starting and Stopping

Start the entire stack:

```bash
make
```

Stop the stack (data is preserved):

```bash
make down
```

Stop the stack and delete all data:

```bash
make clean
```

## Accessing the Website

1. Open a browser and navigate to `https://yuotsubo.42.fr`.
2. The browser will show a security warning because the SSL certificate is self-signed. Click "Advanced" and then "Proceed" to continue.
3. You will see the WordPress homepage.

### Administration Panel

1. Navigate to `https://yuotsubo.42.fr/wp-admin/`.
2. Log in with the administrator credentials.

### Default Users

| Role | Username | Password location |
|---|---|---|
| Administrator | `boss` | `secrets/credentials.txt` line 1 |
| Author | `writer` | `secrets/credentials.txt` line 2 |

## Managing Credentials

All passwords are stored in the `secrets/` directory:

| File | Content |
|---|---|
| `secrets/db_root_password.txt` | MariaDB root password |
| `secrets/db_password.txt` | MariaDB WordPress user password |
| `secrets/credentials.txt` | Line 1: WP admin password, Line 2: WP author password |

To change passwords:

1. Stop the stack: `make clean`
2. Edit the relevant file in `secrets/`
3. Restart: `make`

Note: Changing passwords requires a full clean restart because the old passwords are stored in the database.

## Checking Service Health

View live logs from all services:

```bash
make logs
```

Check that all three containers are running:

```bash
docker compose -f srcs/docker-compose.yml ps
```

Expected output should show `mariadb`, `wordpress`, and `nginx` with status `Up`.

Test HTTPS connectivity:

```bash
curl -kIs https://yuotsubo.42.fr
```

A healthy response starts with `HTTP/1.1 200 OK`.
