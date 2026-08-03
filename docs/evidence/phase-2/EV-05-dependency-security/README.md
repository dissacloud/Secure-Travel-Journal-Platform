# EV-05 — Dependency security and SCA

## Objective

Demonstrate that vulnerable third-party packages are detected before merge
and remain continuously monitored after release.

## Controls

- Pull-request Dependency Review
- High and critical vulnerability gate
- Runtime and development dependency coverage
- Backend and frontend npm audit
- Licence visibility
- OpenSSF package-health information
- Patched-version guidance
- Dependabot alerts
- Dependabot security updates
- Dependabot version lifecycle management
- Aggregate CI Gate enforcement

## Passing scenario

A clean pull request passes Dependency Review and both lockfile audits.

## Blocking scenario

A demonstration pull request introduces a known vulnerable npm package.

Expected result:

- Dependency Review fails
- SCA Audit fails
- CI Gate fails
- Merge is blocked

## Remediation scenario

The unnecessary vulnerable dependency is removed and the lockfile is
regenerated.

Expected result:

- Dependency Review passes
- SCA Audit passes
- CI Gate passes

## Evidence

- 01-clean-dependency-review.png
- 02-vulnerable-dependency-detected.png
- 03-sca-audit-failure.png
- 04-ci-gate-blocked.png
- 05-remediation-pass.png
- Pull request URL
- GHSA identifier
- Package and vulnerable version
- Remediation commit
