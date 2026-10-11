data "aws_iam_policy_document" "enhanced_monitoring_assume" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "monitoring.rds.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"

      values = [
        data.aws_caller_identity.current.account_id
      ]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"

      values = [
        "arn:aws:rds:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:db:${var.db_identifier}"
      ]
    }
  }
}

resource "aws_iam_role" "enhanced_monitoring" {
  name = "${var.name_prefix}-rds-monitoring"

  assume_role_policy = data.aws_iam_policy_document.enhanced_monitoring_assume.json

  tags = {
    Name = "${var.name_prefix}-rds-monitoring"
  }
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  role = aws_iam_role.enhanced_monitoring.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

locals {
  database_log_groups = toset([
    "postgresql",
    "upgrade",
    "iam-db-auth-error"
  ])
}

resource "aws_cloudwatch_log_group" "database" {
  for_each = local.database_log_groups

  name = "/aws/rds/instance/${var.db_identifier}/${each.value}"

  retention_in_days = var.database_log_retention_days

  kms_key_id = aws_kms_key.database_logs.arn

  tags = {
    Name = "${var.name_prefix}-${each.value}"
  }
}
