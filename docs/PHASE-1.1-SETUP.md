# Phase 1.1 — Application Baseline Setup

This package contains the original Secure Travel Journal application baseline:

- React and Vite frontend
- Express API
- PostgreSQL database
- Nginx same-origin reverse proxy
- Non-root application containers
- Liveness and readiness endpoints
- Parameterised SQL queries
- Backend and frontend tests
- Docker Compose integration stack

## Copy into the repository

Copy the following package contents into the root of `Secure-Travel-Journal-Platform`:

```text
.env.example
.gitignore
docker-compose.yml
application/backend/
application/frontend/
tests/integration/
docs/PHASE-1.1-SETUP.md
```

Remove the previous frontend and backend placeholder files.

## Generate local configuration

```bash
cp .env.example .env
```

Change `POSTGRES_PASSWORD` in `.env`. The local value is for development only and must never be committed.

## Run tests locally

```bash
cd application/backend
npm ci
npm test

cd ../frontend
npm ci
npm test
npm run build
```

## Run the full stack

From the repository root:

```bash
docker compose config
docker compose up --build -d
docker compose ps
```

Open:

```text
http://localhost:8080
```

Verify the API through the Nginx proxy:

```bash
curl -fsS http://localhost:8080/api/health/live
curl -fsS http://localhost:8080/api/health/ready
curl -fsS http://localhost:8080/api/journals
```

Or run:

```bash
chmod +x tests/integration/smoke-test.sh
./tests/integration/smoke-test.sh
```

## Stop the environment

Preserve database data:

```bash
docker compose down
```

Delete the local database volume and start clean:

```bash
docker compose down -v
```

## Suggested commit sequence

```text
feat(api): add Express application and health endpoints
feat(database): add PostgreSQL journal schema
feat(api): implement journal CRUD operations
feat(frontend): add travel journal interface
build(container): add hardened application containers and Compose stack
test: add application baseline test coverage
```

## Phase boundary

This phase establishes the workload only. Do not add GitHub Actions security scanners, AWS infrastructure, ECR, EKS, Argo CD or admission policies until the application works and the baseline tag has been created.
