# Repository Security and Governance Model

## Portfolio Implementation

This repository is currently maintained as a single-owner portfolio project.

The `.github/CODEOWNERS` file defines intended ownership of security-sensitive areas of the repository, including:

- CI/CD workflows
- Infrastructure as Code
- Kubernetes manifests
- Application components
- Repository security configuration

Because the repository currently has a single maintainer, mandatory CODEOWNER approval is not enforced. Enabling this control would require an independent reviewer and would otherwise prevent the repository owner from completing the pull-request workflow independently.

## Production Model

In a production organisation, ownership and approval would be separated.

The Security or Platform Engineering team would own security-sensitive components such as:

- `.github/workflows/`
- `.github/CODEOWNERS`
- `.github/dependabot.yml`
- Infrastructure as Code
- Kubernetes configuration
- Security policy and scanning configuration

Changes to these areas would require mandatory independent review from the appropriate CODEOWNER before merge.

Protected branches or repository rulesets would enforce:

- Pull requests for changes to `main`
- Required CI and security checks
- Required CODEOWNER approval for protected components
- Prevention of direct pushes to protected branches
- Independent review of security-sensitive changes

This models separation of duties and prevents a contributor from unilaterally modifying both a security control and the code subject to that control.