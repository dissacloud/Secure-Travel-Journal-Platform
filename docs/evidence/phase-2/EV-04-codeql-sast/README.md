# EV-04 — CodeQL static application security testing

## Objective

Demonstrate semantic analysis of the Secure Travel Journal frontend and
backend before application changes can be merged.

## Control design

- CodeQL advanced setup
- JavaScript and TypeScript analysis
- No-build extraction for interpreted source code
- Security-extended query suite
- Application source-path restriction
- Test-file exclusion
- SARIF results uploaded to GitHub code scanning
- High and critical security findings blocked by repository ruleset
- Aggregate CI Gate validates successful scanner execution
- Documented security triage process

## Passing scenario

A clean pull request completes CodeQL analysis without introducing a
blocking security alert.

Expected result:

- CodeQL SAST completes
- Results are uploaded to GitHub
- CI Gate succeeds
- Merge protection permits the pull request

## Blocking scenario

A controlled demonstration branch introduces unsafe evaluation of
request-controlled data.

Expected result:

- CodeQL identifies `js/code-injection`
- The finding appears in the pull request
- Code scanning merge protection blocks merging
- The finding is remediated before the pull request can progress

## Evidence to capture

- `01-codeql-clean-scan.png`
- `02-codeql-security-alert.png`
- `03-merge-protection-block.png`
- `04-remediated-codeql-pass.png`
- Pull request URL
- CodeQL rule ID
- Security severity
- Remediation commit
