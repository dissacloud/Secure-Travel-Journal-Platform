# Amazon EKS Platform Architecture

## Platform

The Secure Travel Journal runtime uses Amazon EKS Auto Mode.

Kubernetes version:

`1.36`

## Network placement

EKS control-plane networking and Auto Mode compute use the private
application subnets created in Phase 4.2.

Public subnets are not supplied as EKS compute subnets.

Public subnets are reserved for future internet-facing load balancing.

## EKS Auto Mode

The cluster enables:

- managed compute;
- managed networking;
- managed load balancing;
- managed block storage.

The built-in NodePools are:

- `system`
- `general-purpose`

## Kubernetes API

Private endpoint access is always enabled.

Public endpoint access is disabled by default.

During bootstrap, public endpoint access may be temporarily enabled for
a specific operator `/32` CIDR.

Unrestricted `0.0.0.0/0` Kubernetes API access is prohibited.

## Authentication

Cluster authentication uses the Amazon EKS Access API.

The legacy `aws-auth` ConfigMap is not used for human administration.

Cluster creator administrator access is disabled.

Administrator access is granted explicitly through an EKS Access Entry.

## IAM

Separate IAM roles are used for:

- EKS control-plane/Auto Mode infrastructure;
- Auto Mode EC2 nodes;
- future Kubernetes workloads.

Application workloads will use EKS Pod Identity instead of node-role
credentials.

## Logging

All EKS control-plane log categories are enabled:

- API server
- audit
- authenticator
- controller manager
- scheduler

Logs are stored in CloudWatch with retention configured and encryption
using a dedicated KMS key.

## Kubernetes API data encryption

Amazon EKS Kubernetes 1.36 uses default KMS v2 envelope encryption for
Kubernetes API data.

A customer-managed API-data KMS key may be introduced where explicit
key ownership is required.

## Version lifecycle

The cluster uses EKS Standard Support.

Kubernetes versions will be deliberately upgraded before end of standard
support rather than relying on extended-support operation.

## Artifact deployment

The cluster will not rebuild application images.

Future deployment stages consume the trusted ECR image digests produced
and verified during Phase 3.