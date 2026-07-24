#!/usr/bin/env sh
set -eu

BASE_URL="${BASE_URL:-http://localhost:8080}"

printf 'Checking frontend health...\n'
curl --fail --silent --show-error "${BASE_URL}/healthz"

printf '\nChecking API liveness...\n'
curl --fail --silent --show-error "${BASE_URL}/api/health/live"

printf '\nChecking API readiness...\n'
curl --fail --silent --show-error "${BASE_URL}/api/health/ready"

printf '\nChecking journal collection...\n'
curl --fail --silent --show-error "${BASE_URL}/api/journals"

printf '\nSmoke test passed.\n'
