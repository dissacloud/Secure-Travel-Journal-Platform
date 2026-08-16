# EV-07 — Infrastructure-as-Code and Kubernetes security

## Objective

Demonstrate that insecure cloud infrastructure and Kubernetes workload
configuration are detected before merge.

## Controls

- Pinned Checkov scanner
- Terraform static security analysis
- Kubernetes manifest security analysis
- SARIF reporting
- GitHub Code Scanning integration
- Blocking IaC policy enforcement
- Aggregate CI Gate enforcement
- Explicit policy exception process

## Terraform blocking scenario

Introduce an AWS security group permitting:

TCP/22 from 0.0.0.0/0

Expected result:

- Checkov detects CKV_AWS_24
- Terraform security job fails
- CI Gate fails
- Merge is blocked

## Kubernetes blocking scenario

Introduce a Kubernetes workload configured to:

- Run privileged
- Run as UID 0
- Allow privilege escalation

Expected result:

- Checkov identifies workload-security violations
- Kubernetes security job fails
- CI Gate fails
- Merge is blocked

## Remediation

Replace unsafe configuration with hardened configuration and rescan.

## Evidence

- 01-clean-iac-security-pass.png
- 02-terraform-finding.png
- 03-kubernetes-findings.png
- 04-ci-gate-blocked.png
- 05-remediation-pass.png
- 06-checkov-code-scanning.png