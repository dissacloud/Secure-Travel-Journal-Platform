# EV-03 — Gitleaks secret-scanning gate

## Objective

Demonstrate that hardcoded credentials and project-specific secret
patterns are detected before merge.

## Controls

- Complete Git-history checkout
- Gitleaks default detection rules
- Project-specific synthetic secret rule
- Fully pinned Gitleaks Action
- Pinned Gitleaks scanning engine
- Read-only workflow permissions
- Redacted output
- Aggregate CI Gate enforcement
- Documented credential-response procedure

## Passing scenario

A clean pull request completes the Gitleaks job successfully.

## Blocking scenario

A temporary demonstration pull request introduces a synthetic token
matching the `stjp-demo-secret` rule.

Expected result:

- Gitleaks Secret Scan: failed
- CI Gate: failed
- Pull request merge: blocked

## Remediation scenario

The secret-bearing commit is removed from the demonstration branch
history and the pull request is rescanned.

Expected result:

- Gitleaks Secret Scan: passed
- CI Gate: passed

## Evidence to capture

- `01-clean-gitleaks-pass.png`
- `02-secret-detected.png`
- `03-ci-gate-blocked.png`
- `04-remediation-pass.png`
- Pull request URL
- Detected rule ID
- Remediation commit or branch update
