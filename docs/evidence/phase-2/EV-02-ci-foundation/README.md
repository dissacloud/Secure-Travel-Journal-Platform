# EV-02 — Pull-request CI foundation

## Objective

Prove that every pull request must pass application tests, frontend build
validation and container build validation before it can be merged.

## Controls demonstrated

- Reproducible dependency installation using npm ci
- Backend test execution
- Frontend test execution
- Frontend production build
- Backend container build
- Frontend container build
- Aggregate CI gate
- Read-only GitHub token permissions
- Pinned GitHub Actions dependencies
- Job timeouts and concurrency cancellation

## Expected result

The CI Gate succeeds only when all required application and container checks
complete successfully.
