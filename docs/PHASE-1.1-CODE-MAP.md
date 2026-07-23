# Phase 1.1 Code Map

## Request path

```text
Browser
  -> Nginx frontend container on port 8080
      -> React static application
      -> /api requests proxied to backend:5000
          -> Express routes and validation
              -> parameterised PostgreSQL queries
```

## Backend responsibilities

- `src/app.js` constructs the Express application and applies request IDs, Helmet, JSON limits and routes.
- `src/server.js` verifies database availability, starts the API and handles graceful shutdown.
- `src/config/database.js` creates the PostgreSQL connection pool from environment variables.
- `src/routes/health.routes.js` separates liveness from database-backed readiness.
- `src/routes/journal.routes.js` defines the journal API contract.
- `src/controllers/journal.controller.js` implements parameterised journal queries.
- `src/middleware/validate-journal.js` validates UUIDs, field lengths and calendar dates.
- `src/middleware/error-handler.js` provides consistent public errors without exposing stack traces.
- `database/init.sql` creates the journal table and travel-date index.

## Frontend responsibilities

- `src/App.jsx` coordinates API state, health visibility, creation, deletion and refresh.
- `src/components/JournalForm.jsx` captures validated user input.
- `src/components/JournalList.jsx` renders entries or the empty state.
- `src/components/JournalCard.jsx` renders one journal and its delete action.
- `src/services/journal-api.js` centralises API calls, timeouts and safe error handling.
- `nginx/default.conf` serves the React build, proxies `/api`, and applies browser security headers.
- `nginx/nginx.conf` enables Nginx to run as a non-root user on port 8080.

## Baseline tests

- Eight backend tests cover liveness, readiness, CRUD behaviour, validation and parameterised-query inputs.
- Three frontend tests cover initial rendering, journal creation and API failure handling.
- `tests/integration/smoke-test.sh` checks the deployed frontend, API health and journal collection.

## Deliberately deferred controls

The following belong to later phases and are not claimed by this baseline:

- User authentication and authorisation
- AWS Secrets Manager
- GitHub Actions security gates
- ECR signing, SBOM and provenance
- EKS, GitOps and admission policies
- Runtime detection and alerting
