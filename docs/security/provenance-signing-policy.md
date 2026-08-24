# Provenance and Artifact Signing Policy

## Purpose

Trusted container artifacts must be cryptographically attributable to the
approved build workflow and bound to an immutable container digest.

## Artifact identity

The authoritative artifact identity is the OCI SHA-256 image digest.

Tags are metadata and must not be used as the cryptographic trust anchor.

## Build provenance

Every trusted backend and frontend container image must receive SLSA
build provenance.

Provenance must reference:

- the fully-qualified container repository;
- the exact image SHA-256 digest;
- the trusted GitHub Actions build context.

Provenance is generated only by the trusted build workflow running from
the protected main branch.

## SBOM attestations

Every trusted image must have cryptographically signed attestations for:

- SPDX SBOM;
- CycloneDX SBOM.

Each SBOM attestation must reference the same immutable container digest
that was scanned and published during the trusted build.

## Image signing

Trusted container images are signed using Cosign keyless signing.

Signing identity is obtained through GitHub Actions OIDC and Sigstore.

Long-lived signing keys must not be stored in:

- source control;
- GitHub Secrets;
- workflow configuration;
- application configuration.

## Registry storage

Container signatures and registry-pushed attestations are associated with
the immutable Amazon ECR artifact.

## Trust boundary

Signing and attestation are allowed only from the trusted build workflow
running on the protected main branch.

Pull-request workflows must not receive signing authority.

## Verification

The existence of a signature or attestation alone does not authorize
deployment.

A subsequent verification gate must validate:

- artifact digest;
- signature validity;
- expected OIDC issuer;
- expected repository;
- expected workflow;
- source commit;
- source branch;
- provenance;
- SBOM attestations.

Only artifacts that pass verification are eligible for promotion.