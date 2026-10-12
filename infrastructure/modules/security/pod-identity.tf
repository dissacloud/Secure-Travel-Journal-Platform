data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "backend_pod_assume" {
  statement {
    sid    = "AllowBackendPodIdentity"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "pods.eks.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-namespace"

      values = [
        var.kubernetes_namespace
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-service-account"

      values = [
        var.backend_service_account
      ]
    }
  }
}

resource "aws_iam_role" "backend" {
  name = "${var.cluster_name}-backend-pod"

  assume_role_policy = data.aws_iam_policy_document.backend_pod_assume.json

  tags = {
    Name    = "${var.cluster_name}-backend-pod"
    Purpose = "application-runtime"
  }
}

data "aws_iam_policy_document" "backend" {
  statement {
    sid    = "ConnectToApplicationDatabase"
    effect = "Allow"

    actions = [
      "rds-db:connect"
    ]

    resources = [
      "arn:aws:rds-db:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:dbuser:${var.database_resource_id}/${var.application_database_user}"
    ]
  }
}

resource "aws_iam_role_policy" "backend" {
  name = "database-connect"

  role   = aws_iam_role.backend.id
  policy = data.aws_iam_policy_document.backend.json
}

resource "aws_eks_pod_identity_association" "backend" {
  cluster_name = var.cluster_name

  namespace = var.kubernetes_namespace

  service_account = var.backend_service_account

  role_arn = aws_iam_role.backend.arn

  tags = {
    Name = "${var.cluster_name}-backend"
  }
}

data "aws_iam_policy_document" "database_bootstrap_assume" {
  statement {
    sid    = "AllowDatabaseBootstrapPodIdentity"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "pods.eks.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-namespace"

      values = [
        var.kubernetes_namespace
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-service-account"

      values = [
        var.database_bootstrap_service_account
      ]
    }
  }
}

resource "aws_iam_role" "database_bootstrap" {
  name = "${var.cluster_name}-database-bootstrap"

  assume_role_policy = data.aws_iam_policy_document.database_bootstrap_assume.json

  tags = {
    Name    = "${var.cluster_name}-database-bootstrap"
    Purpose = "database-bootstrap"
  }
}

data "aws_iam_policy_document" "database_bootstrap" {
  statement {
    sid    = "ReadRDSMasterCredential"
    effect = "Allow"

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      var.master_secret_arn
    ]
  }

  statement {
    sid    = "DecryptRDSMasterCredential"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]

    resources = [
      var.master_secret_kms_key_arn
    ]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"

      values = [
        "secretsmanager.${data.aws_region.current.region}.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy" "database_bootstrap" {
  name = "database-bootstrap-secret"

  role   = aws_iam_role.database_bootstrap.id
  policy = data.aws_iam_policy_document.database_bootstrap.json
}

resource "aws_eks_pod_identity_association" "database_bootstrap" {
  cluster_name = var.cluster_name

  namespace = var.kubernetes_namespace

  service_account = var.database_bootstrap_service_account

  role_arn = aws_iam_role.database_bootstrap.arn

  tags = {
    Name = "${var.cluster_name}-database-bootstrap"
  }
}