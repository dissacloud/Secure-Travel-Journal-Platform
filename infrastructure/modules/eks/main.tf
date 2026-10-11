resource "aws_eks_cluster" "this" {
  #checkov:skip=CKV_AWS_39:Development cluster permits public API access restricted to the administrator public IP for management from a local VM; private access remains enabled.
  #checkov:skip=CKV_AWS_339:EKS 1.36 is under AWS standard support; Checkov 3.3.26 hard-coded version list ends at 1.35. Review and remove when the rule supports 1.36.
  #checkov:skip=CKV_AWS_58:EKS Kubernetes 1.28+ provides default envelope encryption for Kubernetes API data including secrets using an AWS-owned KMS key.
  name = var.cluster_name

  # Keep the rest of your existing configurationzd` 1

  version = var.cluster_version

  role_arn = aws_iam_role.cluster.arn

  bootstrap_self_managed_addons = false

  deletion_protection = var.deletion_protection

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  access_config {
    authentication_mode = "API"

    bootstrap_cluster_creator_admin_permissions = false
  }

  compute_config {
    enabled = true

    node_pools = [
      "system",
      "general-purpose"
    ]

    node_role_arn = aws_iam_role.node.arn
  }

  kubernetes_network_config {
    ip_family = "ipv4"

    service_ipv4_cidr = var.service_ipv4_cidr

    elastic_load_balancing {
      enabled = true
    }
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }

  vpc_config {
    subnet_ids = var.private_subnet_ids

    endpoint_private_access = true

    endpoint_public_access = var.endpoint_public_access

    public_access_cidrs = (
      var.endpoint_public_access
      ? var.public_access_cidrs
      : []
    )
  }

  upgrade_policy {
    support_type = "STANDARD"
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster,
    aws_iam_role_policy_attachment.node,
    aws_cloudwatch_log_group.control_plane
  ]

  tags = {
    Name = var.cluster_name
  }
}