# Dependency Security and Governance

## Purpose

This policy defines how third-party application and CI/CD dependencies are
introduced, assessed, updated, excepted and removed.

## Security controls

The project uses:

- GitHub Dependency Review for pull-request dependency changes
- npm audit for complete lockfile vulnerability analysis
- Dependabot alerts for newly disclosed vulnerabilities
- Dependabot security updates for automated remediation
- Dependabot version updates for dependency lifecycle management
- OpenSSF Scorecard information for package-health context

## Blocking threshold

Pull requests are blocked when they introduce:

- Critical vulnerabilities
- High-severity vulnerabilities
- A dependency explicitly prohibited by project policy
- A package change that prevents dependency analysis from completing

Runtime and development dependencies are both in scope.

## Review threshold

Moderate and low vulnerabilities must be reviewed using:

- Reachability
- Exploitability
- Application exposure
- Dependency scope
- Fix availability
- Package maintenance status
- Compensating controls

## Licence governance

Licence data is reviewed during dependency changes.

Blocking licence enforcement will be introduced after the current dependency
inventory has been baselined and an approved SPDX allow-list has been tested.

Unknown or unusual licences require manual review before merge.

## Exceptions

A vulnerability exception must contain:

- Advisory or CVE identifier
- Package and affected version
- Technical justification
- Reachability assessment
- Risk owner
- Compensating controls
- Remediation issue
- Expiry date
- Security approval

Permanent blanket exclusions are prohibited.

## Remediation expectations

- Critical: immediate remediation
- High: remediation before merge
- Moderate: triage and time-bound remediation
- Low: security backlog unless risk context increases severity

Removing a direct dependency does not automatically prove that it is absent.
The lockfile and transitive dependency tree must be checked.
