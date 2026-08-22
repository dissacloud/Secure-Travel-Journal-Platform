# Trusted Artifact Policy

## Build principle

Application container images are built once per trusted release.

The exact locally built artifact must pass vulnerability enforcement before
being published to Amazon ECR.

An image must not be rebuilt between security validation and publication.

## Image identity

Trusted artifacts use:

- Git commit SHA as the human-readable release tag.
- OCI image digest as the authoritative deployment identity.

Mutable tags such as `latest` are prohibited.

## Registry controls

Amazon ECR repositories use immutable tags.

A build must fail when an image already exists for the current Git commit.

Trusted builds must not overwrite an existing release artifact.

## Security gate

Images must pass:

- Critical vulnerability blocking.
- Fixable high-severity vulnerability blocking.

Images are pushed only after those controls pass.

## Cloud identity

GitHub Actions authenticates to AWS using OIDC.

Long-lived AWS access keys must not be stored in GitHub.

The publishing role is restricted to the approved ECR repositories.

## Deployment principle

Future deployment stages must reference the approved ECR image by digest.

Deployment workflows must not rebuild the application artifact.