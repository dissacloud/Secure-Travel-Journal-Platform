# Secure Travel Journal Platform

> A security-focused AWS platform demonstrating how application code progresses from an untrusted pull request into a signed, attestable, independently verified container artifact before deployment to a secure AWS runtime.

The **Secure Travel Journal Platform** is a hands-on Cloud Security / DevSecOps portfolio project focused on security engineering across the software-delivery lifecycle.

The application itself is intentionally simple. The primary objective is to demonstrate the security architecture surrounding application delivery and cloud runtime infrastructure.

## What This Project Demonstrates

The project currently demonstrates:

- secure pull-request CI/CD controls;
- separation between untrusted CI and trusted artifact production;
- GitHub OIDC federation to AWS;
- short-lived AWS STS credentials;
- least-privilege IAM;
- container vulnerability gating;
- immutable Amazon ECR artifacts;
- Cosign keyless signing;
- SLSA provenance;
- SPDX and CycloneDX SBOM generation;
- independent artifact verification;
- Infrastructure as Code security;
- secure Terraform state management;
- evidence-driven security validation.

Secure AWS networking, EKS, database, and runtime controls are being implemented incrementally in Phase 4.

---

## Architecture

### Software Supply Chain

```text
Developer
    |
    v
Pull Request
    |
    v
+----------------------------+
| Untrusted PR Environment   |
|                            |
| Tests                      |
| Gitleaks                   |
| CodeQL                     |
| Dependency Review          |
| npm audit                  |
| Hadolint                   |
| Trivy                      |
| Checkov                    |
|                            |
| No trusted AWS identity    |
| No trusted publishing      |
+-------------+--------------+
              |
              | required checks pass
              v
        Protected main
              |
              v
+----------------------------+
| Trusted Build Environment  |
|                            |
| GitHub OIDC                |
| Short-lived AWS role       |
| Build once                 |
| Vulnerability gate         |
| Push to ECR                |
| Sign                       |
| Generate provenance        |
| Generate SBOMs             |
+-------------+--------------+
              |
              v
     Immutable ECR Digest
              |
              v
+----------------------------+
| Independent Verification   |
|                            |
| Digest                     |
| Signer identity            |
| OIDC issuer                |
| Source commit              |
| SLSA provenance            |
| SPDX attestation           |
| CycloneDX attestation      |
+-------------+--------------+
              |
              v
        Trusted Artifact
```

The critical design decision is that **pull-request code is treated as untrusted code**.

Pull requests may execute tests and security scans, but they cannot obtain the trusted AWS identity used to publish and sign release artifacts.

Detailed design:

[`docs/architecture/trusted-software-supply-chain.md`](docs/architecture/trusted-software-supply-chain.md)

---

## Current Status

| Phase | Capability | Status |
|---|---|---|
| Phase 1 | Application baseline | ✅ Complete |
| Phase 2 | Secure PR CI/CD pipeline | ✅ Complete |
| Phase 3 | Trusted software supply chain | ✅ Complete |
| Phase 4.1 | Terraform / AWS infrastructure foundation | ✅ Complete |
| Phase 4.2 | Secure multi-AZ AWS networking | 🚧 In progress |
| Phase 4.3+ | EKS, database, and runtime security | 📋 Planned |

**Current focus:** Phase 4.2 — Secure AWS Networking.

---

## Security Controls

| Security objective | Implementation |
|---|---|
| Secret detection | Gitleaks |
| Static application security testing | CodeQL |
| Dependency-change analysis | GitHub Dependency Review |
| Dependency vulnerability scanning | npm audit |
| Dockerfile security | Hadolint |
| Container vulnerability scanning | Trivy |
| IaC security scanning | Checkov |
| CI/CD cloud authentication | GitHub OIDC |
| Temporary AWS credentials | AWS STS |
| Container registry | Amazon ECR |
| Artifact immutability | SHA-256 digest |
| Artifact signing | Cosign |
| Build provenance | SLSA |
| Software inventory | SPDX + CycloneDX |
| Artifact verification | Cosign + attestations |
| Separation of duties | Build and verifier IAM roles |
| Infrastructure provisioning | Terraform |
| Encryption | AWS KMS |
| Runtime orchestration | Amazon EKS — in progress |
| Database | Amazon RDS PostgreSQL — planned |

---

## Key Security Design Decisions

### Untrusted PRs receive no trusted AWS identity

Pull-request workflows can validate code but cannot publish, sign, or deploy trusted artifacts.

### AWS authentication is federated

GitHub Actions exchanges GitHub OIDC identity for short-lived AWS STS credentials.

Long-lived AWS access keys are not stored in the repository.

### Artifacts are identified by digest

Trusted container artifacts use immutable SHA-256 ECR references rather than relying solely on mutable tags.

```text
repository@sha256:<digest>
```

### Build and verification roles are separated

The artifact publisher and artifact verifier use separate AWS IAM roles.

The verifier requires read access but does not require artifact-publishing privileges.

### Verification fails closed

The project performs both successful and deliberately invalid verification tests.

A mismatched expected source identity or commit must cause artifact verification to fail.

Detailed rationale:

[`docs/security/security-design-decisions.md`](docs/security/security-design-decisions.md)

---

## Trusted Artifact Evidence

Phase 3 captures evidence for the complete trusted-artifact workflow.

| Evidence | Demonstrates |
|---|---|
| Trusted-build workflow | Controlled artifact production |
| ECR digest | Immutable artifact identity |
| SBOM artifacts | SPDX and CycloneDX inventories |
| SLSA provenance | Build provenance |
| Cosign signatures | Cryptographic artifact identity |
| ECR referrers | Associated supply-chain evidence |
| Verification gate | Successful independent verification |
| Negative verification | Fail-closed policy enforcement |
| IAM evidence | Separation between publisher and verifier |

Full evidence:

[`docs/evidence/`](docs/evidence/)

---

## Phase 4 — Secure AWS Runtime

Phase 4 extends the trusted software-supply-chain architecture into the AWS runtime.

The target architecture follows three principal network trust zones:

```text
Internet
   |
   v
Public Ingress Tier
   |
   v
Private Application Tier
   |
   v
Isolated Database Tier
```

The target runtime includes:

- multi-AZ VPC architecture;
- public ingress subnets;
- private application subnets;
- isolated database subnets;
- controlled outbound access;
- VPC Flow Logs;
- CloudWatch logging;
- Amazon EKS;
- Amazon RDS PostgreSQL;
- AWS Secrets Manager;
- AWS KMS;
- controlled application ingress.

Phase 4.2 currently focuses on the secure networking foundation.

Detailed runtime design:

[`docs/architecture/aws-runtime-architecture.md`](docs/architecture/aws-runtime-architecture.md)

---

## Repository Structure

```text
Secure-Travel-Journal-Platform/
|
├── .github/
│   └── workflows/
│       ├── pr-ci.yml
│       └── trusted-build.yml
│
├── application/
│   ├── backend/
│   └── frontend/
│
├── infrastructure/
│   └── bootstrap/
│       ├── terraform-state/
│       └── trusted-build/
│
├── platform/
│   └── ...
│
├── scripts/
│   └── security/
│
├── tests/
│
├── docs/
│   ├── architecture/
│   ├── security/
│   ├── evidence/
│   └── runbooks/
│
├── docker-compose.yml
├── SECURITY.md
└── README.md
```

---

## Technology

**AWS:** Amazon ECR, IAM, STS, KMS, VPC, CloudWatch, EKS, and RDS.

**Infrastructure:** Terraform and Checkov.

**CI/CD:** GitHub Actions, GitHub OIDC, branch protection, and Dependabot.

**Application Security:** Gitleaks, CodeQL, GitHub Dependency Review, and npm audit.

**Container Security:** Docker, Hadolint, and Trivy.

**Software Supply Chain:** Cosign, SLSA provenance, SPDX, CycloneDX, and immutable OCI artifacts.

**Application:** React, Node.js, and PostgreSQL.

---

## Running Locally

Clone the repository:

```bash
git clone https://github.com/dissacloud/Secure-Travel-Journal-Platform.git
cd Secure-Travel-Journal-Platform
```

Start the local application:

```bash
docker compose up --build
```

The local environment exists primarily to provide a realistic application artifact for the project's security controls.

---

## Documentation

Detailed technical material is maintained under [`docs/`](docs/), including:

- [`docs/security/secure-pr-pipeline.md`](docs/security/secure-pr-pipeline.md) — PR trust boundary and security gates;
- [`docs/security/security-design-decisions.md`](docs/security/security-design-decisions.md) — architecture decisions, rationale, risks, and trade-offs;
- [`docs/security/threat-model.md`](docs/security/threat-model.md) — key assets, threats, trust boundaries, and mitigations;
- [`docs/architecture/trusted-software-supply-chain.md`](docs/architecture/trusted-software-supply-chain.md) — trusted artifact architecture;
- [`docs/architecture/aws-runtime-architecture.md`](docs/architecture/aws-runtime-architecture.md) — Phase 4 runtime architecture;
- [`docs/evidence/`](docs/evidence/) — phase-by-phase security evidence;
- [`docs/runbooks/`](docs/runbooks/) — operational and verification procedures.

---

## Security

Security issues should not be disclosed through public GitHub issues.

See [`SECURITY.md`](SECURITY.md) for the repository security policy and reporting process.

---

## Project Direction

The completed project is intended to demonstrate an end-to-end security path:

```text
Secure Pull Request
        |
        v
Trusted Build
        |
        v
Signed + Attested Artifact
        |
        v
Independent Verification
        |
        v
Amazon ECR
        |
        v
Secure AWS Runtime
        |
        v
Amazon EKS
        |
        v
Application
        |
        v
Amazon RDS
```

The objective is not simply to deploy an application to AWS.

The objective is to demonstrate how a Cloud Security / DevSecOps engineer can establish and validate trust from source code through build, artifact production, and cloud runtime infrastructure.
