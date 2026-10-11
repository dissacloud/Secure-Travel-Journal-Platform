# EKS Access Control

## Authentication model

The cluster uses EKS API access entries.

`aws-auth` is not used for human access.

## Bootstrap administration

The IAM principal creating infrastructure does not implicitly retain
Kubernetes administrator privileges.

Bootstrap cluster-creator administrator permissions are disabled.

An explicit administrator access entry is managed through Terraform.

## Public API exposure

Private API access remains enabled.

Public access is disabled by default.

Where workstation bootstrap access is required, the public endpoint is
restricted to an explicit `/32` operator egress address.

`0.0.0.0/0` access is prohibited.

## Workload identity

Application Pods must not rely on the EC2 node IAM role for AWS
permissions.

AWS service access for workloads will use EKS Pod Identity with
workload-specific IAM roles.

## Future access model

Later hardening will separate personas such as:

- platform administrator;
- deployment automation;
- read-only operations;
- security/audit access.

Cluster-wide administrator access will remain limited.