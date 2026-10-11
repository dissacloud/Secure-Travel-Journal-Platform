data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "database_storage_kms" {
  # checkov:skip=CKV_AWS_356:KMS key policies use Resource "*" because the policy is scoped to the KMS key to which it is attached.
  # checkov:skip=CKV_AWS_109:Account principal enables IAM delegation for this KMS key.
  # checkov:skip=CKV_AWS_111:KMS key administration requires management actions and remains scoped to this key.

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
    sid    = "AllowRDSUse"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "rds.amazonaws.com"
      ]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"

      values = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }
}

resource "aws_kms_key" "database_storage" {
  description = "KMS key for ${var.db_identifier} RDS storage"

  enable_key_rotation     = true
  deletion_window_in_days = 30

  # Keep the existing description, rotation, deletion window, and tags.
  policy = data.aws_iam_policy_document.database_storage_kms.json

  tags = {
    Name = "${var.name_prefix}-rds-storage"
  }
}

resource "aws_kms_alias" "database_storage" {
  name = "alias/${var.name_prefix}-rds-storage"

  target_key_id = aws_kms_key.database_storage.key_id
}

data "aws_iam_policy_document" "master_secret_kms" {
  # checkov:skip=CKV_AWS_356:KMS key policies use Resource "*" because the policy is scoped to the KMS key to which it is attached.
  # checkov:skip=CKV_AWS_109:Account principal enables IAM delegation for this KMS key.
  # checkov:skip=CKV_AWS_111:KMS key administration requires management actions and remains scoped to this key.

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
    sid    = "AllowSecretsManagerUse"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "secretsmanager.amazonaws.com"
      ]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"

      values = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }
}

resource "aws_kms_key" "master_secret" {
  description = "KMS key for ${var.db_identifier} RDS master credential"

  enable_key_rotation     = true
  deletion_window_in_days = 30

  # Keep the existing description, rotation, deletion window, and tags.
  policy = data.aws_iam_policy_document.master_secret_kms.json

  tags = {
    Name = "${var.name_prefix}-rds-master-secret"
  }
}

resource "aws_kms_alias" "master_secret" {
  name = "alias/${var.name_prefix}-rds-master-secret"

  target_key_id = aws_kms_key.master_secret.key_id
}

data "aws_iam_policy_document" "database_logs_kms" {
  # checkov:skip=CKV_AWS_356:KMS key policies require Resource "*" because the policy applies only to the KMS key to which it is attached.
  # checkov:skip=CKV_AWS_109:Account principal enables IAM delegation for this KMS key; CloudWatch Logs usage is separately constrained by service principal and encryption context.
  # checkov:skip=CKV_AWS_111:KMS administration requires write actions and remains scoped to this key through the KMS resource policy.

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
        "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/rds/instance/${var.db_identifier}/*"
      ]
    }
  }
}

resource "aws_kms_key" "database_logs" {
  description = "KMS key for ${var.db_identifier} RDS CloudWatch logs"

  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = data.aws_iam_policy_document.database_logs_kms.json

  tags = {
    Name = "${var.name_prefix}-rds-logs"
  }
}

resource "aws_kms_alias" "database_logs" {
  name = "alias/${var.name_prefix}-rds-logs"

  target_key_id = aws_kms_key.database_logs.key_id
}
