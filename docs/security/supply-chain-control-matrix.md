# Software Supply Chain Control Matrix

## Purpose

This control matrix maps software-supply-chain threats to the security
controls implemented by the Secure Travel Journal Platform and identifies
where each control is enforced.

| Threat / Risk | Control | Enforcement |
| --- | --- | --- |
| Untrusted PR gains cloud credentials | PR workflow has no AWS OIDC access | GitHub Actions workflow permissions |
| Long-lived AWS credentials leak | GitHub OIDC → AWS STS | AWS IAM federation |
| Vulnerable image is published | Trivy scan before ECR push | Blocking trusted-build workflow |
| Rebuilt artifact differs from scanned artifact | Build once and scan the same image | Trusted-build workflow design |
| Mutable image is replaced | ECR immutable tags | Amazon ECR |
| Tag points to unexpected bytes | Artifact identity uses OCI digest | OCI SHA-256 digest |
| Package inventory is unknown | Generate SPDX and CycloneDX SBOMs | Syft |
| Build origin cannot be proven | Generate SLSA provenance | GitHub artifact attestation |
| SBOM is detached from image | Attest SBOM against the same OCI digest | GitHub artifact attestation |
| Signing key is stolen | Keyless Cosign signing | Sigstore + GitHub OIDC |
| Signature from wrong identity is accepted | Validate expected issuer and workflow identity | Cosign verification |
| Valid artifact from wrong source is accepted | Verify repository, ref and source commit | GitHub attestation verification |
| Publisher can modify artifacts during verification | Separate read-only verifier role | AWS IAM |
| Verification can be bypassed | Fail-closed Trusted Artifact Gate | GitHub Actions workflow gate |
| Tampered or incorrect provenance is accepted | Controlled negative verification test | Verification test |
| Deployment rebuilds application artifact | Promote existing approved ECR digest | Deployment policy |






## Control Philosophy

The supply-chain controls follow four primary security principles.

### 1. Separate Untrusted and Trusted Execution

Pull-request validation is intentionally separated from artifact
publication.

Unreviewed code does not receive AWS credentials or artifact-signing
authority.

### 2. Prefer Ephemeral Identity

GitHub Actions authenticates to AWS and Sigstore using OIDC-backed
short-lived identities instead of persistent credentials.

### 3. Verify Immutable Artifacts

Container artifacts are identified using their OCI SHA-256 digest.

Security metadata, signatures, provenance and SBOM attestations are bound
to the same immutable digest.

### 4. Separate Production from Verification

The role responsible for verifying artifacts is read-only and separate
from the role responsible for publishing them.

The Trusted Artifact Gate validates both cryptographic integrity and
expected source identity before an artifact becomes eligible for
promotion.