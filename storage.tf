# S3 버킷 (영상 저장용)
resource "aws_s3_bucket" "video_bucket" {
  bucket_prefix = "team1videostorage-1"
}

# ECR 리포지토리 (GitHub Actions와 이름 일치)
resource "aws_ecr_repository" "docker_repo" {
  name         = "team1-images"
  force_delete = true
}