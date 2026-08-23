# Software Bill of Materials Policy

## Purpose

Every trusted application container must have a Software Bill of
Materials generated from the exact immutable container artefact published
to Amazon ECR.

## Source artefact

SBOM generation must target the ECR image using its OCI digest.

Tag-only SBOM generation is not sufficient for a trusted release.

## Formats

Each trusted container must generate:

- SPDX JSON
- CycloneDX JSON

## Generator

SBOM generation uses a version-pinned Syft release.

The Syft version must be recorded with the generated SBOM metadata.

## Validation

Generated SBOMs must:

- be valid JSON;
- identify the expected SBOM format;
- contain package/component inventory;
- successfully complete before the trusted-build workflow passes.

## Integrity

SHA-256 digests are generated for both SBOM documents.

The trusted-build metadata record must contain:

- source Git commit;
- image tag;
- ECR image digest;
- immutable image reference;
- Syft version;
- SPDX SBOM digest;
- CycloneDX SBOM digest.

## Retention

SBOMs are retained as CI artefacts for release evidence.

Long-term storage and cryptographic attestation are handled by subsequent
software-supply-chain controls.

## Deployment relationship

The SBOM must describe the same image digest that is eligible for
deployment.

Deployment must not rebuild the image after SBOM generation.