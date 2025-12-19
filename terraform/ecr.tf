// ECR Repos
resource "aws_ecr_repository" "vault_app_frontend_repo" {
  name                 = "${var.ecr_repo_name}-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "vault_app_backend_repo" {
  name                 = "${var.ecr_repo_name}-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

