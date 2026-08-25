#!/usr/bin/env bash

set -euo pipefail

if [[ "$#" -ne 3 ]]; then
  echo "Usage: $0 <digest-ref> <source-repository> <source-commit>"
  exit 2
fi

DIGEST_REF="$1"
SOURCE_REPOSITORY="$2"
SOURCE_COMMIT="$3"

SIGNER_WORKFLOW="${SOURCE_REPOSITORY}/.github/workflows/trusted-build.yml"

CERTIFICATE_IDENTITY="https://github.com/${SOURCE_REPOSITORY}/.github/workflows/trusted-build.yml@refs/heads/main"

OIDC_ISSUER="https://token.actions.githubusercontent.com"

echo "=== Trusted artifact verification ==="
echo "Artifact: ${DIGEST_REF}"
echo "Repository: ${SOURCE_REPOSITORY}"
echo "Source commit: ${SOURCE_COMMIT}"
echo

echo "=== 1. Verify Cosign signature ==="

cosign verify \
  --certificate-identity "${CERTIFICATE_IDENTITY}" \
  --certificate-oidc-issuer "${OIDC_ISSUER}" \
  "${DIGEST_REF}" \
  >/dev/null

echo "Cosign signature verified."

echo
echo "=== 2. Verify SLSA provenance ==="

gh attestation verify \
  "oci://${DIGEST_REF}" \
  --repo "${SOURCE_REPOSITORY}" \
  --signer-workflow "${SIGNER_WORKFLOW}" \
  --source-ref "refs/heads/main" \
  --source-digest "${SOURCE_COMMIT}"

echo "SLSA provenance verified."

echo
echo "=== 3. Verify SPDX SBOM attestation ==="

gh attestation verify \
  "oci://${DIGEST_REF}" \
  --repo "${SOURCE_REPOSITORY}" \
  --signer-workflow "${SIGNER_WORKFLOW}" \
  --source-ref "refs/heads/main" \
  --source-digest "${SOURCE_COMMIT}" \
  --predicate-type "https://spdx.dev/Document/v2.3"

echo "SPDX attestation verified."

echo
echo "=== 4. Verify CycloneDX SBOM attestation ==="

gh attestation verify \
  "oci://${DIGEST_REF}" \
  --repo "${SOURCE_REPOSITORY}" \
  --signer-workflow "${SIGNER_WORKFLOW}" \
  --source-ref "refs/heads/main" \
  --source-digest "${SOURCE_COMMIT}" \
  --predicate-type "https://cyclonedx.org/bom/v1.6"

echo "CycloneDX attestation verified."

echo
echo "======================================"
echo "TRUSTED ARTIFACT VERIFICATION PASSED"
echo "======================================"