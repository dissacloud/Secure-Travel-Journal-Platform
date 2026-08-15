# EV-06 — Container security controls

## Objective

Demonstrate that container build configuration and resulting runtime
images are security validated before merge.

## Controls

- Hadolint Dockerfile validation
- Approved base-image registry
- Non-root runtime enforcement
- Container image build validation
- Trivy OS vulnerability scanning
- Trivy application-library scanning
- Critical vulnerability blocking
- Fixable high vulnerability blocking
- SARIF reporting to GitHub Code Scanning
- Aggregate CI Gate enforcement

## Passing scenario

Both Dockerfiles pass Hadolint and both resulting images remain below the
defined vulnerability threshold.

## Blocking scenarios

A pull request may be blocked when:

- A runtime image runs as root.
- An unapproved Dockerfile practice is introduced.
- A critical vulnerability exists.
- A high vulnerability with an available fix exists.

## Evidence

- 01-hadolint-clean.png
- 02-container-build-success.png
- 03-trivy-backend-results.png
- 04-trivy-frontend-results.png
- 05-container-security-gate.png
- 06-github-code-scanning-results.png
- Pull request URL
- Any CVE identifiers remediated
- Remediation commit