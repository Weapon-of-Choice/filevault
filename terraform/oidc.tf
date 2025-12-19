// OIDC Provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github_oidc_provider" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}


// Policy that allows creating OIDC providers
resource "aws_iam_policy" "allow_oidc_provider_create" {
  name        = "AllowCreateOIDCProvider"
  description = "Allow creating OIDC providers"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:CreateOpenIDConnectProvider",
          "iam:ListOpenIDConnectProviders",
          "iam:GetOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider"
        ]
        Resource = "*"
      }
    ]
  })
}

// Attach that policy to your terraform‑admin IAM user
resource "aws_iam_user_policy_attachment" "attach_oidc_provider_creation_policy" {
  user       = var.terraform_admin_user_iam_name
  policy_arn = aws_iam_policy.allow_oidc_provider_create.arn
}


// IAM Role for GitHub Actions
resource "aws_iam_role" "github_action_role" {
  name = "GitHubActionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_oidc_provider.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo_url}:*"
          },
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

// Policy: allow ECR authorization token
resource "aws_iam_role_policy" "github_action_ecr_authorization_policy" {
  name = "ecr-authorization-policy"
  role = aws_iam_role.github_action_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowAuthorizationToECR",
        Effect = "Allow",
        Action = "ecr:GetAuthorizationToken",
        Resource = "*"
      }
    ]
  })
}

// Policy: allow push to frontend ECR
resource "aws_iam_role_policy" "github_action_push_to_frontend_ecr_policy" {
  name = "push-to-frontend-ecr"
  role = aws_iam_role.github_action_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowPushToFrontendECR",
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ],
        Resource = aws_ecr_repository.vault_app_frontend_repo.arn
      }
    ]
  })
}

// Policy: allow push to backend ECR
resource "aws_iam_role_policy" "github_action_push_to_backend_ecr_policy" {
  name = "push-to-backend-ecr"
  role = aws_iam_role.github_action_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowPushToBackendECR",
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ],
        Resource = aws_ecr_repository.vault_app_backend_repo.arn
      }
    ]
  })
}
