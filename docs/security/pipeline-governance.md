# CI/CD Pipeline Governance

## Trust boundary

The pull-request workflow is an untrusted verification environment.

It must not receive:

- AWS credentials
- OIDC cloud identity
- Repository write access
- Package publication rights
- Production deployment permissions

Deployment credentials will be introduced only in a separate trusted release workflow.

## GitHub token

The workflow defaults to read-only repository access.

Individual jobs receive additional permissions only where technically required.

Examples:

- CodeQL: `security-events: write`
- Trivy SARIF upload: `security-events: write`
- Checkov SARIF upload: `security-events: write`

The aggregate CI Gate receives no GitHub token permissions.

## Third-party actions

External actions must:

1. Be reviewed before introduction.
2. Be pinned to a full 40-character commit SHA.
3. Be monitored by Dependabot.
4. Use least-privilege token permissions.

Floating branches and tags are prohibited.

## Pull-request execution

`pull_request_target` is prohibited for code-validation workflows.

Pull requests are evaluated using the normal `pull_request` trust model.

## Merge enforcement

`main` requires the aggregate `CI Gate`.

The gate fails if any mandatory security or quality control does not complete successfully.

## Security exceptions

Scanner failures must not be bypassed by:

- `continue-on-error`
- blanket allowlists
- disabling security jobs
- changing blocking exit codes

Exceptions require documented risk acceptance.

## Production model

In a multi-engineer environment, changes to CI/CD workflows, IaC,
Kubernetes configuration and security policies would require independent
review from the platform or security CODEOWNER.

The portfolio repository is currently maintained by a single contributor,
so CODEOWNERS expresses intended ownership without mandatory self-review.