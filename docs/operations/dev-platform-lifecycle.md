# Development Platform Lifecycle

## Cost considerations

The development platform contains AWS resources that can incur charges even
while the application is not deployed:

- EKS control plane
- Regional NAT Gateway
- Multi-AZ RDS PostgreSQL
- CloudWatch Logs
- Customer-managed KMS keys

Charges depend on the resources’ configuration, runtime and usage. An
environment with no application Pods may still contain chargeable
infrastructure. Check AWS billing after deployment and after teardown.

The application and its future ALB are intentionally not deployed in this
phase. Include them in the cost review if they are added later.

## Deletion protection

RDS and EKS deletion protection reduce the risk of accidental deletion. A
Terraform destroy can be blocked while either protection setting is enabled:

```text
terraform destroy
        ↓
blocked by deletion protection
        ↓
EKS deletion protection
RDS deletion protection
```

Do not permanently disable deletion protection to make cleanup easier.
Disable it through Terraform only when you intend to tear down the development
environment.

## Planned teardown procedure

1. Capture the required Phase 4 and Phase 4.5 evidence.
2. In the dev Terraform variables, temporarily set
   `database_deletion_protection` and `eks_deletion_protection` to `false`.
3. From `infrastructure/environments/dev`, create and review a normal plan:

   ```bash
   terraform plan -out=disable-protection.tfplan
   terraform show disable-protection.tfplan
   ```

4. Apply that plan only if it contains the intended deletion-protection
   changes and no unexpected changes:

   ```bash
   terraform apply disable-protection.tfplan
   ```

5. Create and review a fresh destroy plan:

   ```bash
   terraform plan -destroy -out=phase-4-destroy.tfplan
   terraform show phase-4-destroy.tfplan
   ```

6. Apply the destroy plan only after confirming it removes the intended
   development resources:

   ```bash
   terraform apply phase-4-destroy.tfplan
   ```

7. Verify in AWS that the RDS instance, EKS cluster and other project
   resources have been removed. Check for retained snapshots, log groups or
   other resources that may remain after teardown.
8. Restore both deletion-protection values to `true` before the next
   deployment. Do not apply the configuration just to restore those values
   while the environment is meant to remain destroyed; the next deployment
   plan should create the resources with protection enabled.

Use the same Terraform environment, workspace and state used to deploy the
platform. Create a new plan after changing the protection settings; do not
reuse an older plan file.