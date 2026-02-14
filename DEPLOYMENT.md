# CrewCert Deployment Guide

## Server Requirements

- Ubuntu 22.04+ or Debian 12+
- Docker installed
- nginx installed
- PostgreSQL 15+
- Redis (optional, for background jobs)

## Server Setup (melapus.xeri.eu)

### 1. PostgreSQL Database

```bash
# Create database and user
sudo -u postgres psql

CREATE USER crewcert WITH PASSWORD 'your_secure_password';
CREATE DATABASE crewcert_production OWNER crewcert;
GRANT ALL PRIVILEGES ON DATABASE crewcert_production TO crewcert;
\q
```

### 2. nginx Configuration

Create `/etc/nginx/sites-available/crewcert.xeri.eu`:

```nginx
server {
    listen 80;
    server_name crewcert.xeri.eu;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name crewcert.xeri.eu;

    ssl_certificate /etc/letsencrypt/live/crewcert.xeri.eu/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/crewcert.xeri.eu/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    client_max_body_size 100M;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 86400;
    }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/crewcert.xeri.eu /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 3. SSL Certificate

```bash
sudo certbot certonly --nginx -d crewcert.xeri.eu
```

## GitHub Secrets Required

Set these in repository Settings → Secrets and variables → Actions:

| Secret | Description |
|--------|-------------|
| `KAMAL_REGISTRY_USERNAME` | Docker Hub username (johndel) |
| `KAMAL_REGISTRY_PASSWORD` | Docker Hub access token |
| `RAILS_MASTER_KEY` | Rails master key (from config/master.key) |
| `CREWCERT_DATABASE_PASSWORD` | PostgreSQL password for crewcert user |

## Deployment

### Automatic (GitHub Actions)

Push to the `prod` branch to trigger automatic deployment:

```bash
git checkout prod
git merge main
git push origin prod
```

### Manual (Kamal)

```bash
# Set environment variables
export KAMAL_REGISTRY_USERNAME=johndel
export KAMAL_REGISTRY_PASSWORD=your_docker_token
export RAILS_MASTER_KEY=$(cat config/master.key)
export CREWCERT_DATABASE_PASSWORD=your_db_password

# Deploy
kamal deploy
```

## Post-Deployment

### Run Seeds (first time only)

```bash
kamal app exec "rails db:seed"
```

### Run Migrations

```bash
kamal app exec "rails db:migrate"
```

### View Logs

```bash
kamal app logs
```

### Rails Console

```bash
kamal app exec -i "rails console"
```

## Configuration

### Environment Variables

| Variable | Description |
|----------|-------------|
| `DATABASE_HOST` | PostgreSQL host (172.17.0.1 for Docker) |
| `CREWCERT_DATABASE_PASSWORD` | Database password |
| `RAILS_MASTER_KEY` | Rails encryption key |
| `APP_HOST` | Application hostname |
| `GOOD_JOB_EXECUTION_MODE` | Background job mode (async) |
| `REDIS_URL` | Redis connection URL |

### Credentials (config/credentials.yml.enc)

Contains:
- `smtp` - Mailgun SMTP settings
- `cloudflare_r2` - R2 storage credentials
- `gemini_api_key` - Google Gemini API key for OCR

Edit with:
```bash
EDITOR=nano rails credentials:edit
```

## Architecture

```
Internet → nginx (443) → Kamal Proxy (8000) → Rails App (3000)
                                                    ↓
                                              PostgreSQL (5432)
                                                    ↓
                                              Cloudflare R2 (storage)
                                                    ↓
                                              Google Gemini (OCR)
```

## Troubleshooting

### Container won't start

Check logs:
```bash
kamal app logs
docker logs crewcert-web
```

### Database connection issues

Ensure PostgreSQL allows connections from Docker:
```bash
# /etc/postgresql/15/main/pg_hba.conf
host    all    all    172.17.0.0/16    md5
```

### SSL issues

Renew certificate:
```bash
sudo certbot renew
```
