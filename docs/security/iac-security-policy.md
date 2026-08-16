# Infrastructure-as-Code Security Policy

## Purpose

Infrastructure and Kubernetes configuration must be security validated
before merge and before deployment.

## Scope

The policy covers:

- Terraform infrastructure
- AWS resource configuration
- Kubernetes manifests
- Future Helm or Kustomize configuration

## Terraform requirements

Terraform changes must not introduce:

- Unrestricted administrative network access
- Publicly exposed sensitive services
- Unencrypted storage
- Overly permissive IAM permissions
- Disabled security logging
- Unsafe EKS configuration
- Hardcoded credentials
- Security controls intentionally disabled without justification

## Kubernetes requirements

Workloads must not introduce:

- Privileged containers
- Root execution
- Unnecessary Linux capabilities
- Privilege escalation
- Host networking unless explicitly justified
- Host PID or IPC access
- Missing resource controls
- Unsafe mutable deployment configuration

## Enforcement

Checkov runs during pull-request validation.

A failed Checkov policy blocks the CI Gate.

## Exceptions

A policy exception must document:

- Checkov rule ID
- Resource
- Environment
- Technical justification
- Risk owner
- Compensating control
- Expiry date
- Remediation issue
- Security approval

Blanket Checkov suppression is prohibited.

Exceptions must be scoped to the smallest possible resource and policy.