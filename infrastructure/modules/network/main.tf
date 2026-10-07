data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  az_configuration = {
    for index, az in var.availability_zones :
    az => {
      public_cidr   = var.public_subnet_cidrs[index]
      private_cidr  = var.private_subnet_cidrs[index]
      database_cidr = var.database_subnet_cidrs[index]
    }
  }

  flow_log_name = "/aws/vpc/${var.name_prefix}/flow-logs"
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  ingress = []
  egress  = []

  tags = {
    Name = "${var.name_prefix}-default-sg-restricted"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

resource "aws_subnet" "public" {
  for_each = local.az_configuration

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value.public_cidr

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-public-${each.key}"

    Tier = "public"

    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "private" {
  for_each = local.az_configuration

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value.private_cidr

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-private-${each.key}"

    Tier = "private"

    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "database" {
  for_each = local.az_configuration

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value.database_cidr

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-database-${each.key}"

    Tier = "database"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-public-rt"
  }
}

resource "aws_route" "public_internet" {
  route_table_id = aws_route_table.public.id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_nat_gateway" "this" {
  vpc_id = aws_vpc.this.id

  connectivity_type = "public"
  availability_mode = "regional"

  depends_on = [
    aws_internet_gateway.this
  ]

  tags = {
    Name = "${var.name_prefix}-regional-nat"
  }
}

resource "aws_route_table" "private" {
  for_each = local.az_configuration

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-private-${each.key}-rt"
  }
}

resource "aws_route" "private_internet" {
  for_each = aws_route_table.private

  route_table_id = each.value.id

  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table" "database" {
  for_each = local.az_configuration

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-database-${each.key}-rt"
  }
}

resource "aws_route_table_association" "database" {
  for_each = aws_subnet.database

  subnet_id      = each.value.id
  route_table_id = aws_route_table.database[each.key].id
}


data "aws_iam_policy_document" "flow_logs_kms" {
  # checkov:skip=CKV_AWS_356:KMS key policies require Resource "*" because the policy is scoped to the KMS key it is attached to.
  # checkov:skip=CKV_AWS_109:KMS key policy grants account-level key administration to the account root principal; service usage is separately constrained by encryption context.
  # checkov:skip=CKV_AWS_111:KMS key administration requires write/management actions; access is scoped by the key policy and service-specific encryption context.

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
        "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:${local.flow_log_name}*"
      ]
    }
  }
}

resource "aws_kms_key" "flow_logs" {
  description = "KMS key for ${var.name_prefix} VPC Flow Logs"

  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = data.aws_iam_policy_document.flow_logs_kms.json

  tags = {
    Name = "${var.name_prefix}-flow-logs"
  }
}

resource "aws_kms_alias" "flow_logs" {
  name = "alias/${var.name_prefix}-vpc-flow-logs"

  target_key_id = aws_kms_key.flow_logs.key_id
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name = local.flow_log_name

  retention_in_days = var.flow_log_retention_days
  kms_key_id        = aws_kms_key.flow_logs.arn

  tags = {
    Name = "${var.name_prefix}-vpc-flow-logs"
  }
}

data "aws_iam_policy_document" "flow_logs_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "vpc-flow-logs.amazonaws.com"
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
        "arn:aws:ec2:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:vpc-flow-log/*"
      ]
    }
  }
}

resource "aws_iam_role" "flow_logs" {
  name = "${var.name_prefix}-vpc-flow-logs"

  assume_role_policy = data.aws_iam_policy_document.flow_logs_assume_role.json
}

data "aws_iam_policy_document" "flow_logs_publish" {
  statement {
    sid    = "PublishVPCFlowLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"
    ]
  }

  # statement {
  #   sid    = "DescribeCloudWatchLogs"
  #   effect = "Allow"

  #   actions = [
  #     "logs:DescribeLogGroups",
  #     "logs:DescribeLogStreams"
  #   ]

  #   resources = [
  #     "*"
  #   ]
  # }
}

resource "aws_iam_role_policy" "flow_logs" {
  name = "${var.name_prefix}-vpc-flow-logs"

  role   = aws_iam_role.flow_logs.id
  policy = data.aws_iam_policy_document.flow_logs_publish.json
}

resource "aws_flow_log" "this" {
  vpc_id = aws_vpc.this.id

  traffic_type = "ALL"

  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn

  iam_role_arn = aws_iam_role.flow_logs.arn

  max_aggregation_interval = 60

  tags = {
    Name = "${var.name_prefix}-vpc-flow-log"
  }
}

