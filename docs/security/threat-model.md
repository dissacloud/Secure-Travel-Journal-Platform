# Threat Model

## Scope

This threat model focuses on the software-delivery pipeline, trusted artifact production, and the AWS runtime architecture of the Secure Travel Journal Platform.

It is intentionally scoped to the portfolio platform and does not claim to be a complete production threat model.

## Key Assets

- source code;
- GitHub repository and branch-protection rules;
- GitHub Actions workload identity;
- AWS IAM roles;
- Amazon ECR repositories;
- trusted container images;
- Cosign signatures;
- SLSA provenance;
- SPDX and CycloneDX SBOMs;
- Terraform state;
- runtime AWS infrastructure;
- application and database data.

## Trust Boundaries

### Pull Request Boundary

Pull-request code is considered untrusted until it passes required validation and is merged through repository controls.

### Trusted Build Boundary

Only code on the protected `main` branch is permitted to enter trusted artifact production.

### AWS Identity Boundary

GitHub Actions receives short-lived AWS credentials through OIDC. The trust relationship must constrain which repository and workflow contexts may assume each role.

### Artifact Boundary

A trusted artifact is identified by immutable digest and is accompanied by expected signatures, provenance, and SBOM attestations.

### Runtime Boundary

Phase 4 separates public ingress, private application workloads, and isolated database resources into distinct network trust zones.

## Threats and Mitigations

| Threat | Security concern | Mitigation |
|---|---|---|
| Secret committed to source | Credential exposure | Gitleaks, no long-lived AWS CI keys |
| Vulnerable dependency introduced | Known software vulnerability | Dependency Review, package audit |
| Vulnerable container published | Exploitable runtime package | Trivy vulnerability gates |
| Insecure Dockerfile | Excess privilege or weak image configuration | Hadolint, container review |
| Insecure IaC change | Cloud misconfiguration | Checkov, review, documented exceptions |
| Pull request obtains AWS credentials | CI privilege escalation | No trusted AWS identity in PR context |
| Artifact overwritten by mutable tag | Loss of artifact identity | Immutable ECR digest references |
| Artifact rebuilt after scanning | Validation/deployment drift | Build once and promote by digest |
| Malicious or unexpected signer | Supply-chain impersonation | Cosign identity and issuer verification |
| Artifact from wrong commit | Source/artifact mismatch | Source commit verification |
| Missing or forged provenance | Weak origin traceability | SLSA provenance verification |
| SBOM does not match expected artifact evidence | Weak software inventory assurance | SBOM attestations and integrity hashes |
| Verification policy is overly permissive | Invalid artifact accepted | Controlled negative verification |
| Publisher compromise grants verification authority | Weak separation of duties | Separate publisher and verifier IAM roles |
| Terraform state exposed | Infrastructure metadata leakage | KMS encryption, restricted access, versioning |
| Application workload directly internet-exposed | Increased attack surface | Planned private application tier |
| Database directly internet-exposed | Data-tier exposure | Planned isolated database tier |

## Security Assumptions

The current design assumes:

- GitHub repository administrative controls remain trusted;
- protected-branch rules are configured correctly;
- AWS OIDC trust policies are narrowly scoped;
- third-party GitHub Actions are pinned and reviewed;
- AWS account administrative access is protected outside this repository;
- runtime security controls are still being implemented as Phase 4 progresses.

## Out of Scope

The current portfolio phase does not claim complete coverage of:

- production SOC operations;
- enterprise identity governance;
- full application threat modelling;
- DDoS architecture;
- multi-account AWS landing-zone governance;
- production backup and disaster recovery;
- regulatory compliance certification.

These can be added if the project evolves beyond the current portfolio scope.

## Review Triggers

This threat model should be revisited when:

- new AWS services are introduced;
- EKS runtime controls are implemented;
- internet-facing ingress is added;
- authentication or authorization is added to the application;
- deployment automation is introduced;
- new trust relationships are created.
