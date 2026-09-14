# Security Design Decisions

This document records the major security architecture decisions made in the Secure Travel Journal Platform and the rationale behind them.

## 1. Treat Pull Requests as Untrusted

### Decision

Pull-request workflows are permitted to validate code but are not given the AWS identity used to publish trusted artifacts.

### Security rationale

Pull requests execute code that has not yet crossed the final review and merge boundary. Giving that execution context trusted cloud permissions would allow untrusted code to interact with privileged AWS resources.

### Risk reduced

- credential theft through CI;
- unreviewed artifact publication;
- cloud-resource manipulation from pull requests;
- supply-chain privilege escalation.

### Trade-off

Some cloud-backed integration tests may need a separate, tightly constrained test identity if introduced later.

---

## 2. Use GitHub OIDC Instead of Long-Lived AWS Access Keys

### Decision

GitHub Actions authenticates to AWS through OIDC federation and receives short-lived AWS STS credentials.

### Security rationale

Static access keys create a durable secret that must be stored, rotated, protected, and eventually revoked.

OIDC allows AWS to trust a constrained workload identity rather than a stored credential.

### Risk reduced

- long-lived secret leakage;
- forgotten CI credentials;
- manual key rotation failures;
- credential reuse outside the intended workflow.

### Trade-off

OIDC trust policies require careful subject and repository constraints. A broad trust policy would undermine the control.

---

## 3. Build Once and Promote by Immutable Digest

### Decision

Trusted container images are built once and identified using their immutable ECR SHA-256 digest.

### Security rationale

Rebuilding between security validation and deployment can produce a different artifact even when the source commit has not changed.

Digest-based identity allows the same artifact that was scanned and verified to be referenced later.

### Risk reduced

- tag mutation;
- rebuild drift;
- ambiguity about which binary was validated;
- accidental deployment of a different image.

### Trade-off

Operational tooling must preserve and consume digest references rather than relying only on human-friendly tags.

---

## 4. Separate Artifact Publishing and Verification Roles

### Decision

Artifact production and independent artifact verification use separate AWS IAM roles.

### Security rationale

The verifier does not need publication privileges to determine whether an artifact satisfies trust policy.

Separating the roles makes the control easier to reason about and demonstrates separation of duties.

### Risk reduced

- unnecessary write access;
- verifier compromise becoming a publishing compromise;
- blurred responsibility between producer and validator.

### Trade-off

The design introduces additional IAM policy and role management.

---

## 5. Generate Both SPDX and CycloneDX SBOMs

### Decision

The trusted build generates both SPDX and CycloneDX software bills of materials.

### Security rationale

Both formats are widely used across security and software-supply-chain tooling. Producing both demonstrates interoperability and preserves software inventory evidence alongside the artifact.

### Risk reduced

The SBOM itself does not block vulnerabilities, but it reduces uncertainty about artifact composition and supports future vulnerability, licensing, and incident-response workflows.

### Trade-off

The workflow generates and validates additional evidence objects.

---

## 6. Record Build Provenance

### Decision

Trusted artifacts receive SLSA-style provenance attestation associated with the immutable image digest.

### Security rationale

A trusted artifact should be traceable back to the workflow and source context that produced it.

### Risk reduced

- weak source-to-artifact traceability;
- ambiguity about artifact origin;
- inability to verify expected build context.

### Trade-off

Provenance is only valuable when verification checks the expected source and workflow identity.

---

## 7. Keyless Sign Trusted Container Images

### Decision

Trusted container images are signed using Cosign keyless signing.

### Security rationale

Keyless signing avoids introducing another long-lived private signing key while still binding the artifact to an authenticated workflow identity.

### Risk reduced

- static signing-key storage;
- signing-key rotation burden;
- unmanaged signing credentials.

### Trade-off

Verification must correctly validate certificate identity and the expected OIDC issuer.

---

## 8. Verification Must Fail Closed

### Decision

The trusted artifact workflow includes a controlled negative test using deliberately invalid expected source identity data.

### Security rationale

A successful verification command only proves the happy path. A trust policy must also reject invalid identity or provenance.

### Risk reduced

- permissive verification rules;
- false confidence from a command that always succeeds;
- accidental acceptance of artifacts from an unexpected source.

### Trade-off

Negative tests add workflow execution time but provide high-value control evidence.

---

## 9. Treat Terraform State as Security-Sensitive Data

### Decision

Remote Terraform state is protected with encryption, access controls, versioning, and destruction safeguards.

### Security rationale

Terraform state can contain resource identifiers, configuration details, dependency relationships, and sensitive infrastructure metadata.

### Risk reduced

- unauthorized state access;
- accidental destruction;
- loss of historical state versions;
- unencrypted state storage.

### Trade-off

The backend infrastructure itself must be managed carefully because it becomes part of the platform's control plane.

---

## 10. Document Accepted Scanner Exceptions

### Decision

IaC or security-scanner findings are not treated as automatically authoritative. Where an exception is accepted, the rationale is documented.

### Security rationale

Security engineering is a risk decision process, not a scanner-score optimisation exercise.

### Risk reduced

- silently ignored findings;
- architecture changes made only to satisfy tooling;
- loss of auditability around accepted risk.

### Trade-off

Exceptions require maintenance and should be revisited when architecture or threat context changes.
