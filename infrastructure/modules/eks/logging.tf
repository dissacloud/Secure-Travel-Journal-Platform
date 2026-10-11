locals {
  control_plane_log_group_name = "/aws/eks/${var.cluster_name}/cluster"
}

data "aws_iam_policy_document" "control_plane_logs_kms" {
  #checkov:skip=CKV_AWS_356:KMS key policies use Resource "*" to represent only the key to which this policy is attached.
  #checkov:skip=CKV_AWS_109:Account principal enables IAM delegation for this key; CloudWatch Logs usage is constrained to the cluster log-group encryption context.
  #checkov:skip=CKV_AWS_111:Key administration is scoped to this key and account principal; service cryptographic usage is constrained by encryption context.

  # Keep your existing statements here.
  statement {
    sid    = "EnableAccountAdministration"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions = [
      "kms:*"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "logs.${data.aws_region.current.region}.amazonaws.com"
      ]
    }

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"

      values = [
        "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:${local.control_plane_log_group_name}"
      ]
    }
  }
}

resource "aws_kms_key" "control_plane_logs" {
  description = "KMS key for ${var.cluster_name} EKS control-plane logs"

  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = data.aws_iam_policy_document.control_plane_logs_kms.json

  tags = {
    Name = "${var.cluster_name}-control-plane-logs"
  }
}

resource "aws_kms_alias" "control_plane_logs" {
  name = "alias/${var.cluster_name}-control-plane-logs"

  target_key_id = aws_kms_key.control_plane_logs.key_id
}

resource "aws_cloudwatch_log_group" "control_plane" {
  name = local.control_plane_log_group_name

  retention_in_days = var.control_plane_log_retention_days

  kms_key_id = aws_kms_key.control_plane_logs.arn

  tags = {
    Name = "${var.cluster_name}-control-plane-logs"
  }
}
