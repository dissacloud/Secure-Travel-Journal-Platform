# Static Application Security Testing Triage Process

## Purpose

This document defines how CodeQL findings are assessed, remediated,
accepted or escalated within the Secure Travel Journal Platform.

## Enforcement policy

### Critical findings

- Pull request must be blocked.
- Finding must be investigated immediately.
- Finding must be remediated before merge.
- Security acceptance requires explicit documented approval.

### High-severity findings

- Pull request must be blocked.
- Finding must be remediated before merge unless a time-bound risk
  exception has been approved.
- Internet exposure and data sensitivity must be considered during triage.

### Medium-severity findings

- Finding must be reviewed before merge.
- Reachable and externally exploitable findings should be remediated.
- Deferred findings require an owner, remediation ticket and target date.

### Low-severity findings

- Finding should be recorded in the security backlog.
- Repeated low-severity patterns may require a shared remediation control.

## Triage information

Every finding must be assessed using:

- CodeQL rule ID
- Security severity
- Precision
- Affected source and sink
- Exploitability
- Reachability
- Internet exposure
- Data sensitivity
- Available remediation
- Compensating controls
- Finding owner

## Dismissal policy

A finding must not be dismissed solely to make the pipeline pass.

A dismissal must record:

- Technical justification
- Risk owner
- Security reviewer
- Compensating control
- Expiry or review date
- Remediation reference

Repository-wide blanket dismissals are prohibited.

## Remediation verification

A finding is considered remediated only when:

1. The vulnerable data flow has been removed or controlled.
2. Application tests still pass.
3. CodeQL rescans the pull request.
4. The alert is no longer present in the pull request.
5. The security gate permits the change to progress.
