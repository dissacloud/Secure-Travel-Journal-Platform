# Platform Security Control Matrix

This matrix maps platform risks to their controls and the layer responsible
for enforcing each control.

| Risk | Control | Enforcement |
|---|---|---|
| Terraform state disclosure | Encrypted, versioned S3 backend | S3 and KMS |
| Concurrent Terraform state writes | S3 native lockfile, when enabled in the backend configuration | Terraform S3 backend |
| Public node exposure | EKS nodes use private subnets | VPC routing |
| Unrestricted Kubernetes API | Private endpoint and no unrestricted public CIDR | EKS endpoint configuration |
| Implicit cluster-admin access | Cluster creator admin access disabled; access granted through EKS access entries | EKS Access API |
| Missing cluster audit trail | EKS control-plane log types enabled | EKS and CloudWatch Logs |
| Public database exposure | `publicly_accessible = false` | RDS |
| Internet-routable database subnet | Database subnets use isolated route tables | VPC routing |
| Broad database network access | PostgreSQL access limited to the application Pod security group on TCP 5433 | EC2 security groups |
| Plaintext database password in Terraform | RDS-managed master credential stored in Secrets Manager | RDS and Secrets Manager |
| Broad application AWS permissions | Separate EKS Pod Identity role for the backend | EKS and IAM |
| Backend reads the master password | Backend role has no master-secret permission | IAM |
| Bootstrap reads arbitrary secrets | Bootstrap role is scoped to the specific RDS-managed secret | IAM |
| Pod inherits node permissions | Application permissions are assigned through Pod Identity, not the node role | EKS and IAM |
| Unrelated workloads receive database network access | Dedicated backend NodeClass, NodePool, and Pod security group | EKS Auto Mode and EC2 security groups |
| Lateral Pod traffic | Default-deny network policy with explicit required egress | Kubernetes NetworkPolicy |
| Privileged Pods | Restricted Pod Security Admission labels on the namespace | Kubernetes |
| Accidental RDS deletion | RDS deletion protection; final-snapshot behaviour follows the Terraform configuration | RDS |
| Network activity is not visible | VPC Flow Logs enabled | VPC and CloudWatch Logs |

## Verification note

Before describing a control as implemented, verify it against the Terraform
configuration, Kubernetes manifests, or live AWS/Kubernetes output. In
particular, check the S3 lockfile setting, API endpoint CIDRs, enabled
control-plane log types, and RDS final-snapshot settings.