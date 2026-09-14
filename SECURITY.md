# Security Policy

## Project Scope

The Secure Travel Journal Platform is a Cloud Security and DevSecOps portfolio project designed to demonstrate secure software delivery and AWS infrastructure security practices.

The application is intentionally simple. The primary security focus of the repository is the architecture surrounding the application, including:

* CI/CD security controls;
* software supply-chain security;
* AWS identity federation;
* least-privilege IAM;
* container security;
* artifact signing and verification;
* Infrastructure as Code security;
* AWS network security;
* Kubernetes/EKS security;
* security evidence and validation.

This repository is not currently operated as a production service and does not contain production customer data.

## Supported Versions

The actively supported version of the project is the latest code on the protected `main` branch.

| Version                         | Supported |
| ------------------------------- | --------- |
| `main`                          | ✅ Yes     |
| Historical branches and commits | ❌ No      |

Security fixes are applied to the current implementation rather than backported to previous portfolio milestones.

## Reporting a Security Issue

Please do not publicly disclose suspected vulnerabilities through a GitHub issue.

If GitHub Private Vulnerability Reporting is available for this repository, use:

**Security → Advisories → Report a vulnerability**

to report the issue privately.

If private vulnerability reporting is unavailable, contact the repository owner privately through the contact information associated with the GitHub profile.

Please include enough information to reproduce and assess the issue where possible, including:

* the affected component or file;
* a description of the vulnerability;
* reproduction steps;
* expected and observed behaviour;
* potential security impact;
* relevant logs or screenshots;
* suggested remediation, if known.

Do not include real credentials, access tokens, private keys or other sensitive information in the report.

## Security Testing

Security testing should be performed only against resources owned by the project maintainer or resources for which explicit authorization has been granted.

Do not:

* attempt to access third-party systems or data;
* perform destructive testing;
* intentionally disrupt AWS or GitHub services;
* use denial-of-service techniques;
* expose real credentials or secrets;
* attempt social-engineering attacks.

Controlled negative security tests used by this project use synthetic or deliberately invalid data.

## Security Controls

The repository currently demonstrates controls including:

* Gitleaks secret scanning;
* CodeQL static analysis;
* dependency review and vulnerability scanning;
* Hadolint Dockerfile analysis;
* Trivy container vulnerability scanning;
* Checkov Infrastructure as Code scanning;
* protected pull-request security gates;
* GitHub OIDC federation to AWS;
* short-lived AWS STS credentials;
* immutable Amazon ECR image digests;
* Cosign keyless container signing;
* SLSA provenance;
* SPDX and CycloneDX SBOM generation;
* independent artifact verification;
* separation between artifact publishing and verification IAM roles.

Runtime AWS and EKS security controls are being implemented incrementally as part of Phase 4.

## Secret Handling

Real AWS credentials and other long-lived secrets must not be committed to this repository.

GitHub Actions authenticates to AWS using GitHub OIDC and short-lived AWS STS credentials where cloud access is required.

Synthetic secrets may be used in controlled security tests to verify that secret-scanning controls fail closed.

## Dependency and Container Vulnerabilities

Dependency and container findings are assessed according to severity, exploitability, fix availability and project context.

Where a security scanner finding is intentionally accepted or suppressed, the decision should be documented with its rationale rather than silently excluded.

## Infrastructure Security

Infrastructure changes are managed through Terraform and are expected to pass applicable formatting, validation and security-policy checks before merge.

Security-sensitive infrastructure decisions should favour:

* least privilege;
* private-by-default networking;
* encryption;
* short-lived credentials;
* immutable artifacts;
* separation of duties;
* auditable security controls;
* evidence-based validation.

## Disclosure

Because this is a portfolio and learning environment rather than a production service, formal response or remediation SLAs are not provided.

Valid security reports will be reviewed on a best-effort basis and remediated where appropriate.
