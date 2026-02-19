# -------------------------
# ECR 리포지토리 - Worker
# -------------------------
resource "aws_ecr_repository" "worker_repo" {
  name         = "team1-worker"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"
}

# -------------------------
# ECR 리포지토리 - Web
# -------------------------
resource "aws_ecr_repository" "web_repo" {
  name         = "team1-web"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"
}

# -------------------------
# ECR 리포지토리 - WAS
# -------------------------
resource "aws_ecr_repository" "was_repo" {
  name         = "team1-was"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"
}
