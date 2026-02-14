# CrewCert

Maritime crew certificate management system.

## Setup

### Prerequisites

- Ruby 3.4+
- PostgreSQL
- Node.js 20+
- Redis (production)

### Installation

```bash
bundle install
yarn install
bin/rails db:setup
```

### Development

```bash
bin/dev
```

## External Services

### Cloudflare R2 (File Storage)

Used for storing certificate documents in production.

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com) → **R2 Object Storage**
2. Create bucket (e.g., `crewcert`)
3. Create API Token: **Manage account** → **R2 API Tokens** → **Create API token**
   - Permissions: Object Read & Write
   - Specify bucket: your bucket name

Add to Rails credentials (`bin/rails credentials:edit`):

```yaml
r2:
  access_key_id: your_access_key_id
  secret_access_key: your_secret_access_key
  endpoint: https://ACCOUNT_ID.r2.cloudflarestorage.com
  bucket: crewcert
  region: auto
```

### Google Gemini AI (OCR)

Used for extracting data from certificate documents.

1. Go to [Google AI Studio](https://aistudio.google.com/apikey)
2. Create API key

Add to Rails credentials (`bin/rails credentials:edit`):

```yaml
google:
  gemini_api_key: your_api_key
```

### Redis (Production)

Used for distributed rate limiting and caching.

Set environment variable:

```bash
REDIS_URL=redis://localhost:6379/0
```

### SMTP (Email)

Add to Rails credentials:

```yaml
smtp:
  username: your_smtp_username
  password: your_smtp_password
  host: smtp.example.com
  port: 587
```

Or use environment variables:

```bash
SMTP_USERNAME=...
SMTP_PASSWORD=...
SMTP_HOST=...
SMTP_PORT=587
```

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `RAILS_MASTER_KEY` | Master key for credentials | Production |
| `DATABASE_URL` | PostgreSQL connection | Production |
| `REDIS_URL` | Redis connection | Production |
| `APP_HOST` | Application hostname | Production |

## Testing

```bash
bundle exec rspec
```

## Security

```bash
bundle exec brakeman
bundle exec bundler-audit
```
