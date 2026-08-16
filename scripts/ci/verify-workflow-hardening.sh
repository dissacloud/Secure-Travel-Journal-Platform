#!/usr/bin/env bash

set -euo pipefail

WORKFLOW_DIR=".github/workflows"
PR_WORKFLOW=".github/workflows/pr-ci.yml"

failures=0

echo "Checking GitHub Actions security policy..."

while IFS= read -r file; do
  echo "Checking action references in ${file}"

  while IFS= read -r ref; do
    [[ -z "${ref}" ]] && continue

    # Local actions cannot be pinned to Git SHAs.
    if [[ "${ref}" == ./* ]]; then
      continue
    fi

    if [[ ! "${ref}" =~ @[0-9a-fA-F]{40}$ ]]; then
      echo "::error file=${file}::Action is not pinned to a full 40-character commit SHA: ${ref}"
      failures=1
    fi
  done < <(
    sed -nE \
      's/^[[:space:]]*(-[[:space:]]*)?uses:[[:space:]]*([^[:space:]#]+).*/\2/p' \
      "${file}"
  )

done < <(
  find "${WORKFLOW_DIR}" \
    -type f \
    \( -name '*.yml' -o -name '*.yaml' \) \
    -print
)

if grep -RInE \
  '^[[:space:]]*pull_request_target:' \
  "${WORKFLOW_DIR}"; then

  echo "::error::pull_request_target is prohibited in verification workflows."
  failures=1
fi

if grep -RInE \
  'persist-credentials:[[:space:]]*true' \
  "${WORKFLOW_DIR}"; then

  echo "::error::Checkout credentials must not persist after checkout."
  failures=1
fi

if grep -RInE \
  'permissions:[[:space:]]*write-all' \
  "${WORKFLOW_DIR}"; then

  echo "::error::write-all GitHub token permissions are prohibited."
  failures=1
fi

# The PR validation workflow must never receive cloud identity or repository
# modification permissions. Deployment identity belongs in a separate,
# trusted release workflow.
for forbidden_permission in \
  'id-token:[[:space:]]*write' \
  'contents:[[:space:]]*write' \
  'packages:[[:space:]]*write' \
  'actions:[[:space:]]*write' \
  'pull-requests:[[:space:]]*write'
do
  if grep -nE "${forbidden_permission}" "${PR_WORKFLOW}"; then
    echo "::error file=${PR_WORKFLOW}::Forbidden write permission detected: ${forbidden_permission}"
    failures=1
  fi
done

if [[ "${failures}" -ne 0 ]]; then
  echo "GitHub Actions security policy failed."
  exit 1
fi

echo "GitHub Actions security policy passed."