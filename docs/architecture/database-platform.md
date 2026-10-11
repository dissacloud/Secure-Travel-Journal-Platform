# PostgreSQL Data Platform

## Platform

The Secure Travel Journal Platform uses Amazon RDS for PostgreSQL.

Engine:

`PostgreSQL 17`

## Network isolation

RDS is deployed exclusively into the isolated database subnets.

The database:

- has no public endpoint;
- does not reside in public subnets;
- does not have direct NAT or Internet Gateway routing.

## Network authorization

PostgreSQL accepts connections only from the dedicated application
database-client security group.

CIDR-based VPC-wide PostgreSQL access is not permitted.

## Port

The platform uses PostgreSQL TCP port `5433`.

## Encryption at rest

RDS storage is encrypted with a dedicated customer-managed AWS KMS key.

Encrypted RDS storage also protects associated backups and snapshots.

## Encryption in transit

PostgreSQL TLS is enforced through:

`rds.force_ssl = 1`

## Credentials

The RDS master credential is generated and managed by Amazon RDS through
AWS Secrets Manager.

Terraform does not store a configured plaintext database password.

The Secrets Manager secret is encrypted with a separate customer-managed
AWS KMS key.

The master credential is reserved for database administration/bootstrap
and must not become the application's normal runtime identity.

## Authentication

IAM database authentication is enabled.

Future workload integration may use IAM authentication or a
least-privilege application credential retrieved through workload
identity.

## Availability

Multi-AZ deployment is enabled.

## Recovery

Automated backups are retained for seven days.

Deletion protection is enabled.

A final snapshot is required during intentional database deletion.

## Logging and monitoring

PostgreSQL, upgrade and IAM authentication error logs are exported to
CloudWatch Logs.

RDS Enhanced Monitoring is enabled.

## Application integration

Future EKS application workloads receive database connectivity through a
dedicated Pod network security boundary.

The application must not receive unrestricted VPC-level database access.