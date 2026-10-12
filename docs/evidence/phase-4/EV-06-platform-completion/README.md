# EV-06 — Secure AWS Runtime Platform

## Objective

Demonstrate the complete AWS security architecture supporting the future
Secure Travel Journal workload.

## Infrastructure chain

Terraform remote state
→ multi-AZ VPC
→ private Amazon EKS Auto Mode
→ isolated Amazon RDS PostgreSQL
→ EKS Pod Identity
→ Pod network security
→ database authorization

## Positive authorization test

The backend Pod Identity IAM role is permitted to perform:

`rds-db:connect`

against the specific RDS resource and the future:

`traveljournal_app`

database identity.

Expected result:

`allowed`

## Negative authorization test

The same backend role is tested against the RDS master credential in
Secrets Manager.

Expected result:

`implicitDeny`

The backend runtime must never receive the database master credential.

## Database-bootstrap isolation

The bootstrap role is allowed to retrieve only the RDS-managed master
secret.

An unrelated Secrets Manager resource must remain denied.

## Network isolation

The PostgreSQL security group accepts TCP/5433 only from the dedicated
application database-client security group.

The database is non-public and located in isolated subnets without a
default internet route.

## Kubernetes security

The Travel Journal namespace enforces:

- Restricted Pod Security Admission;
- default-deny NetworkPolicy;
- explicit backend egress;
- dedicated backend Auto Mode NodeClass and NodePool;
- EKS Pod Identity;
- separate Pod network security groups.

## Result

The infrastructure platform is considered ready for controlled
application deployment by immutable artifact digest.