# Hardcoded Secret Response Runbook

## Purpose

This runbook defines the response when Gitleaks detects a potential
credential, API key, token, password or private key.

## Pipeline response

1. Block the pull request.
2. Do not copy the detected value into tickets, chat messages or screenshots.
3. Confirm whether the finding is a real secret or a false positive.
4. Identify the credential owner and affected system.
5. Revoke or rotate a confirmed credential immediately.
6. Review access and audit logs for possible unauthorised use.
7. Remove the credential from the current code.
8. Remove it from Git history where necessary.
9. Replace it with an approved secret-management mechanism.
10. Record the incident, response, owner and remediation evidence.

## Important principle

Deleting a secret in a later commit is not sufficient because the value
may remain accessible in Git history.

## False positives

False positives must not be suppressed casually.

Any exception must include:

- Finding fingerprint
- Technical justification
- Risk owner
- Security approval
- Expiry date
- Compensating control
- Remediation reference

Repository-wide or permanent blanket allowlists are prohibited.
