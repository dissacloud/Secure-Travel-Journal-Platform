# Terraform State Security

## Purpose

Terraform state for the Secure Travel Journal Platform is stored remotely
to protect infrastructure metadata and support controlled concurrent
operations.

## Backend

Terraform state uses Amazon S3.

The backend provides:

- remote state storage;
- native S3 state locking;
- bucket versioning;
- KMS encryption;
- public-access blocking;
- TLS-only access.

## State locking

Terraform uses the S3 backend `use_lockfile` capability.

DynamoDB-based locking is not used because it is deprecated for new S3
backend implementations.

## Encryption

State objects are encrypted using a dedicated AWS KMS key.

Automatic KMS key rotation is enabled.

## Recovery

S3 bucket versioning is enabled so previous state versions can be
recovered following accidental modification or deletion.

## Destruction protection

The state bucket and KMS key use Terraform lifecycle protection to reduce
the risk of accidental destruction.

## Source control

The following must never be committed:

- Terraform state files;
- Terraform plan files;
- local backend configuration;
- environment-specific tfvars containing sensitive information.

Terraform dependency lock files are committed.

## Authentication

AWS credentials are not stored in Terraform configuration.

Local operators use their existing AWS identity.

Future infrastructure automation will use GitHub OIDC and a dedicated
least-privilege infrastructure role.