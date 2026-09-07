# EV-06 — Phase 3 Trusted Software Supply Chain

## Objective

Demonstrate end-to-end production and verification of trusted container
artifacts.

## Trusted artifact chain

Source commit
→ protected main
→ GitHub OIDC
→ trusted build
→ vulnerability gate
→ immutable ECR image
→ OCI digest
→ SPDX/CycloneDX SBOM
→ SLSA provenance
→ SBOM attestations
→ Cosign keyless signature
→ independent verification
→ Trusted Artifact Gate

## Positive test

A legitimate backend and frontend artifact produced by the trusted build
must successfully verify:

- Cosign signature;
- GitHub Actions signer identity;
- GitHub OIDC issuer;
- source repository;
- source branch;
- source commit;
- SLSA provenance;
- SPDX attestation;
- CycloneDX attestation.

Expected result:

`TRUSTED`

## Negative test

Verification is repeated using an intentionally incorrect expected source
commit.

The artifact remains cryptographically valid but does not satisfy the
expected provenance policy.

Expected result:

`REJECTED`

Successful verification of the deliberately incorrect source context is a
test failure.

## Deployment decision

Only artifacts passing the Trusted Artifact Gate are considered eligible
for future deployment.