data "aws_caller_identity" "current" {}

locals {
  state_bucket_name = "${var.project_name}-tfstate-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
}

# ------------------------------------------------------------
# KMS key policy
# ------------------------------------------------------------

data "aws_iam_policy_document" "terraform_state_kms" {
  # checkov:skip=CKV_AWS_356:This is a KMS key policy. AWS KMS requires Resource "*" in key policies, where "*" represents the KMS key to which the policy is attached.
  # checkov:skip=CKV_AWS_109:This is the standard KMS account-principal statement that enables IAM delegation for this key; it is not an unconstrained IAM identity policy.
  # checkov:skip=CKV_AWS_111:This is a KMS resource policy using the AWS account principal to enable IAM delegation; access remains governed by IAM and the key policy.

  statement {
    sid    = "EnableIAMUserPermissions"
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
}

# ------------------------------------------------------------
# KMS key for Terraform state
# ------------------------------------------------------------

resource "aws_kms_key" "terraform_state" {
  description = "KMS key for Secure Travel Journal Terraform state"

  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = data.aws_iam_policy_document.terraform_state_kms.json

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "terraform_state" {
  name          = "alias/${var.project_name}-terraform-state"
  target_key_id = aws_kms_key.terraform_state.key_id
}

# ------------------------------------------------------------
# Terraform state bucket
# ------------------------------------------------------------

resource "aws_s3_bucket" "terraform_state" {
  # checkov:skip=CKV_AWS_144:Cross-region replication is outside the scope of this single-region portfolio environment.
  # checkov:skip=CKV2_AWS_62:S3 event notifications are not required for the Terraform state bootstrap use case.
  # checkov:skip=CKV_AWS_18:Dedicated S3 access logging is outside the current bootstrap scope and will be evaluated as part of the platform audit-logging design.

  bucket = local.state_bucket_name

  lifecycle {
    prevent_destroy = true
  }
}

# ------------------------------------------------------------
# Block all public access
# ------------------------------------------------------------

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ------------------------------------------------------------
# Versioning
# ------------------------------------------------------------

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ------------------------------------------------------------
# Lifecycle management for old state versions
# ------------------------------------------------------------

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  depends_on = [
    aws_s3_bucket_versioning.terraform_state
  ]

  rule {
    id     = "terraform-state-lifecycle"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# ------------------------------------------------------------
# Server-side encryption
# ------------------------------------------------------------

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.terraform_state.arn
    }

    bucket_key_enabled = true
  }
}

# ------------------------------------------------------------
# Require TLS
# ------------------------------------------------------------

data "aws_iam_policy_document" "terraform_state" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type = "*"

      identifiers = [
        "*"
      ]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.terraform_state.arn,
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "false"
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = data.aws_iam_policy_document.terraform_state.json

  depends_on = [
    aws_s3_bucket_public_access_block.terraform_state
  ]
}