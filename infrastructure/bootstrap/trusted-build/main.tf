data "aws_caller_identity" "current" {}

locals {
  github_oidc_provider_arn = join("", [
    "arn:aws:iam::",
    data.aws_caller_identity.current.account_id,
    ":oidc-provider/token.actions.githubusercontent.com"
  ])

  github_oidc_subject = join("", [
    "repo:",
    var.github_owner,
    "@",
    var.github_owner_id,
    "/",
    var.github_repository,
    "@",
    var.github_repository_id,
    ":ref:refs/heads/main"
  ])

  ecr_repositories = {
    backend  = "${var.project_name}/backend"
    frontend = "${var.project_name}/frontend"
  }
}

resource "aws_ecr_repository" "application" {
  for_each = local.ecr_repositories

  name                 = each.value
  image_tag_mutability = "IMMUTABLE"
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
  }
}

resource "aws_ecr_lifecycle_policy" "application" {
  for_each = aws_ecr_repository.application

  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1

        description = "Expire untagged images after seven days"

        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }

        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2

        description = "Retain the most recent 30 tagged images"

        selection = {
          tagStatus = "tagged"
          tagPrefixList = [
            "sha-"
          ]
          countType   = "imageCountMoreThan"
          countNumber = 30
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "github_trust" {
  statement {
    sid    = "GitHubOIDCTrustedBuild"
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        local.github_oidc_provider_arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        local.github_oidc_subject
      ]
    }
  }
}

resource "aws_iam_role" "github_trusted_build" {
  name = "${var.project_name}-github-trusted-build"

  assume_role_policy = data.aws_iam_policy_document.github_trust.json

  max_session_duration = 3600
}

data "aws_iam_policy_document" "ecr_publish" {
  statement {
    sid    = "ECRAuthentication"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "PublishApplicationImages"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]

    resources = [
      for repository in aws_ecr_repository.application :
      repository.arn
    ]
  }
}

resource "aws_iam_role_policy" "ecr_publish" {
  name = "${var.project_name}-ecr-publish"
  role = aws_iam_role.github_trusted_build.id

  policy = data.aws_iam_policy_document.ecr_publish.json
}