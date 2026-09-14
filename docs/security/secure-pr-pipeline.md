# Secure Pull Request Pipeline

## Objective

The pull-request pipeline validates application, container, dependency, and Infrastructure as Code changes before they are eligible to enter the trusted build path.

The pipeline is intentionally designed around the assumption that **pull-request code is untrusted**.

## Trust Boundary

Pull requests may:

- compile and test application code;
- execute static security analysis;
- scan dependencies and container images;
- lint Dockerfiles;
- validate Terraform and Kubernetes configuration;
- build temporary local artifacts for validation.

Pull requests may not:

- obtain the trusted AWS role used for artifact publication;
- publish trusted images to Amazon ECR;
- sign trusted artifacts;
- create trusted release attestations;
- deploy workloads.

This separation reduces the risk that unreviewed code can use CI execution to obtain cloud identity or publish artifacts that appear trusted.

## Security Controls

### Secret Scanning — Gitleaks

Gitleaks scans repository changes for credentials and secret-like material.

Synthetic test secrets may be used in controlled validation to prove that the gate blocks expected findings.

### Static Analysis — CodeQL

CodeQL provides static application security analysis for supported application code.

The control is intended to identify security-relevant code patterns before merge.

### Dependency Review

GitHub Dependency Review evaluates dependency changes introduced by pull requests.

This adds change-focused visibility before new third-party components enter the trusted build path.

### Dependency Vulnerability Scanning

Application dependencies are checked for known vulnerabilities using the relevant package-manager audit tooling.

The objective is to prevent known vulnerable dependencies from entering trusted artifact production without review.

### Dockerfile Analysis — Hadolint

Hadolint checks Dockerfiles for insecure or poor container build practices.

The Docker build configuration is treated as security-sensitive source code rather than operational glue.

### Container Vulnerability Scanning — Trivy

Temporary container images are scanned for operating-system and application-library vulnerabilities.

The trusted build later performs its own artifact-specific vulnerability gate before publication.

### Infrastructure as Code Scanning — Checkov

Terraform and Kubernetes configuration are scanned before merge.

Where a finding is accepted, the exception should be explicit and justified rather than silently suppressed.

## Aggregate CI Gate

Individual scanner jobs are combined into an explicit CI gate.

A pull request is considered eligible for merge only when required validation controls have completed successfully.

This provides one clear policy decision point rather than relying on humans to interpret a collection of unrelated job statuses.

## GitHub Actions Hardening

The workflow applies controls such as:

- reduced job permissions;
- pinned third-party action revisions;
- `persist-credentials: false` where appropriate;
- explicit job dependencies;
- fail-closed security gates.

## Relationship to the Trusted Build

Passing pull-request CI does **not** make an artifact trusted.

It only makes reviewed code eligible to reach the protected `main` branch.

Trusted artifact production is performed separately after merge, using a controlled GitHub OIDC identity and a dedicated AWS publishing role.

For the artifact trust model, see:

[`../architecture/trusted-software-supply-chain.md`](../architecture/trusted-software-supply-chain.md)
