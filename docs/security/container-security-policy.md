# Container Security Policy

## Purpose

This policy defines build-time security requirements for container images
used by the Secure Travel Journal Platform.

## Dockerfile controls

Dockerfiles are evaluated using Hadolint.

Security requirements include:

- Runtime containers must not run as root.
- Dockerfiles must use approved image registries.
- Mutable `latest` tags are prohibited.
- Security-relevant Hadolint warnings must be resolved before merge.
- Scanner suppressions require documented justification.

## Vulnerability scanning

Every application container is scanned with Trivy after it has been built.

The scan covers:

- Operating-system packages
- Application libraries
- High-severity vulnerabilities
- Critical vulnerabilities

## Blocking policy

### Critical

All critical vulnerabilities block release regardless of fix availability.

### High

High vulnerabilities with an available remediation block release.

High vulnerabilities without a vendor fix require documented triage.

### Medium and Low

Medium and low findings are tracked through the security backlog unless
risk context requires escalation.

## Remediation

Preferred remediation order:

1. Upgrade the affected package.
2. Upgrade the base image.
3. Remove an unnecessary package.
4. Replace the dependency or image.
5. Apply a documented compensating control.
6. Use a time-bound exception only where remediation is not currently possible.

## Exceptions

A vulnerability exception must document:

- CVE or advisory identifier
- Affected image
- Affected package
- Severity
- Exploitability
- Reachability
- Fix availability
- Compensating controls
- Risk owner
- Expiry date
- Remediation ticket

Permanent blanket exclusions are prohibited.