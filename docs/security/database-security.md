# Database Security Controls

## Trust boundary

Database connectivity follows:

Travel Journal workload
→ application DB-client security group
→ PostgreSQL security group
→ RDS

## Prohibited access

The following are prohibited:

- public RDS access;
- `0.0.0.0/0` PostgreSQL ingress;
- VPC-wide PostgreSQL ingress;
- storing database passwords in Git;
- storing database passwords in Terraform variables;
- application use of the RDS master credential.

## Encryption

Data at rest uses a customer-managed KMS key.

Credentials use a separate customer-managed KMS key.

TLS is required for PostgreSQL connections.

## Credential governance

The RDS master credential is managed through Secrets Manager.

Application access must use a workload-specific database identity.

## Detection

PostgreSQL logs and IAM authentication errors are exported to CloudWatch.

Enhanced Monitoring provides operating-system telemetry.

## Recovery

Automated backups, Multi-AZ operation, deletion protection and final
snapshot protection are enabled.