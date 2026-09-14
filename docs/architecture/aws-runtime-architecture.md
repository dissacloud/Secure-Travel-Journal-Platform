# AWS Runtime Architecture

## Objective

Phase 4 extends the trusted software-supply-chain architecture into a secure AWS runtime environment.

The runtime is designed around explicit network trust zones, controlled identity, encryption, observability, and the principle that verified artifacts should remain identifiable through deployment.

## Current Status

- **Phase 4.1:** Terraform / AWS infrastructure foundation — complete.
- **Phase 4.2:** Secure multi-AZ networking — in progress.
- **Phase 4.3+:** EKS, database, and runtime security — planned.

This document describes the target architecture. Planned controls should not be interpreted as already implemented.

## Network Trust Zones

```text
Internet
   |
   v
+-------------------------+
| Public Ingress Tier     |
|                         |
| Internet-facing ingress |
| Controlled entry point  |
+------------+------------+
             |
             v
+-------------------------+
| Private Application     |
| Tier                    |
|                         |
| EKS workloads           |
| No direct public nodes  |
+------------+------------+
             |
             v
+-------------------------+
| Isolated Database Tier  |
|                         |
| Amazon RDS PostgreSQL   |
| No direct internet path |
+-------------------------+
```

## Phase 4.2 — Secure Networking

The networking foundation is intended to provide:

- a multi-AZ VPC;
- separate public, private application, and isolated database subnets;
- explicit route tables per trust zone;
- controlled outbound access from private application networks;
- no unnecessary internet route for database subnets;
- security-group separation between ingress, application, and database tiers;
- VPC Flow Logs for network visibility.

## Public Ingress Tier

The public tier exists only for components that require internet reachability.

The target design keeps public exposure concentrated at the ingress boundary rather than exposing application compute directly.

## Private Application Tier

EKS worker capacity and application workloads are intended to run in private subnets.

The application tier should communicate outward only where required and should communicate with the database tier through explicitly permitted network paths.

## Isolated Database Tier

Amazon RDS PostgreSQL is planned for isolated database subnets.

The database tier should:

- have no direct internet route;
- accept traffic only from approved application security groups;
- use encryption at rest;
- obtain credentials through a managed secret mechanism rather than hard-coded application configuration.

## Identity

Runtime workloads should use AWS-native workload identity rather than embedded static AWS credentials.

The exact EKS identity implementation should preserve least privilege at workload level.

## Artifact Trust

The runtime architecture should preserve the identity of the verified container artifact.

The target deployment path is:

```text
Source
  |
  v
Trusted Build
  |
  v
Signed + Attested ECR Digest
  |
  v
Independent Verification
  |
  v
Approved Immutable Digest
  |
  v
EKS Workload
```

Where practical, deployment controls should prevent an unapproved or unexpected artifact from being promoted into the runtime.

## Secrets

Application secrets should be externalised from source code and container images.

AWS Secrets Manager is the planned secret store for runtime credentials such as database access.

## Encryption

The runtime design should use AWS KMS-backed encryption where supported and appropriate, including infrastructure control-plane data and data services.

## Logging and Detection

The runtime target includes security-relevant telemetry such as:

- VPC Flow Logs;
- CloudWatch logs;
- EKS control-plane and workload logs where appropriate;
- AWS service audit data.

Logging should support investigation, validation, and future detection engineering rather than exist only as a checkbox control.

## Infrastructure as Code

Runtime infrastructure is provisioned through Terraform.

Infrastructure changes are expected to pass:

- formatting;
- validation;
- security scanning;
- review;
- documented risk acceptance where exceptions are required.

## Design Principles

The Phase 4 runtime is guided by:

- private-by-default networking;
- least privilege;
- short-lived or workload-native identity;
- encryption;
- immutable artifact identity;
- separation of trust zones;
- evidence-based validation;
- explicit security exceptions.

## Planned Validation Evidence

As Phase 4 progresses, evidence should demonstrate:

- VPC and subnet topology;
- route-table separation;
- private application placement;
- isolated database placement;
- security-group paths;
- VPC Flow Logs;
- EKS workload identity;
- secret retrieval;
- runtime deployment by immutable digest;
- logging and security telemetry.
