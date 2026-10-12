# EKS Workload Security Architecture

## Objective

Application workloads run with separate compute, network and AWS
identities instead of inheriting broad permissions from the EKS nodes.

## Backend compute boundary

The Travel Journal backend uses a dedicated EKS Auto Mode NodeClass and
NodePool.

The NodePool is tainted so unrelated workloads cannot schedule onto the
backend compute boundary without explicitly declaring the corresponding
toleration.

## Node identity

Backend nodes use a dedicated IAM role.

The role contains only the permissions required by EKS Auto Mode nodes
and Amazon ECR image retrieval.

Application AWS permissions are not placed on the node role.

## Pod networking

Backend Pods use separate Pod networking through the Auto Mode NodeClass.

Node traffic uses the EKS cluster security group.

Backend Pod traffic uses the application database-client security group.

Only that Pod network identity is permitted by the RDS security group.

## Kubernetes network policy

The Travel Journal namespace uses deny-by-default ingress and egress.

Backend egress is explicitly allowed only for:

- cluster DNS;
- EKS Pod Identity;
- PostgreSQL in the isolated database tier.

Ingress will be added only when application exposure is implemented.

## Pod Security Admission

The namespace enforces the Kubernetes Restricted Pod Security Standard.

Future application manifests must conform to the restricted policy.

## AWS workload identity

AWS access uses EKS Pod Identity.

Static AWS credentials and node-role inheritance are not used for
application permissions.

## Backend database identity

The backend IAM role may perform only:

`rds-db:connect`

against:

`traveljournal_app`

on the specific RDS instance.

The database user itself will be created during controlled database
bootstrap.

## Database bootstrap identity

A separate Kubernetes service account and IAM role may retrieve the
RDS-managed master credential.

That role can read only the specific RDS secret and decrypt only its KMS
key.

The backend application cannot retrieve the master credential.

## Future deployment

Application deployment must explicitly select the secured backend
NodePool and use the backend service account.

The trusted image digest from Phase 3 remains the authoritative workload
artifact.