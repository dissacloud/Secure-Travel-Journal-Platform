# Trusted Artifact Verification Policy

## Purpose

An artifact must not be considered deployable solely because it exists in
Amazon ECR or possesses a cryptographic signature.

Trusted artifacts must pass explicit identity, provenance and SBOM
verification before promotion.

## Authoritative identity

The authoritative software artifact is the immutable OCI digest.

Tags are metadata and must not be used as the deployment trust anchor.

## Signature policy

Container images must have a valid Sigstore/Cosign signature.

Verification must require:

- GitHub Actions as the expected OIDC issuer;
- the Secure Travel Journal repository as the signing source;
- the trusted-build workflow as the signer;
- the protected main branch as the signing ref.

A cryptographically valid signature from any other identity must fail.

## Provenance policy

Every deployable container must have verifiable SLSA provenance.

The provenance must match:

- expected repository;
- trusted-build workflow;
- source commit;
- protected main branch;
- exact OCI image digest.

## SBOM policy

Both trusted SBOM attestations must exist and verify:

- SPDX;
- CycloneDX.

The SBOM attestations must refer to the same OCI digest being evaluated
for deployment.

## Cloud permissions

Artifact verification uses a dedicated read-only AWS IAM role.

The verifier must not receive ECR image publication permissions.

## Failure behavior

Verification fails closed.

Failure of any required trust control makes the artifact ineligible for
promotion.

Security controls must not be bypassed using:

- continue-on-error;
- shell error suppression;
- wildcard signer identities;
- wildcard OIDC issuers;
- mutable image tags;
- unverified provenance.

## Deployment eligibility

Only an artifact that passes the Trusted Artifact Gate is eligible for
deployment.

Passing verification establishes provenance and identity. It does not
assert that the software is free of vulnerabilities; vulnerability policy
is enforced by the earlier trusted-build security controls.

## Kubernetes admission

The future EKS deployment layer will independently enforce artifact trust
using an admission policy.

Cluster-side admission enforcement is intentionally deferred until the
EKS workload platform is deployed.