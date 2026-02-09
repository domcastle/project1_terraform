# S3 버킷 (영상 저장용)
resource "aws_s3_bucket" "video_bucket" {
  bucket_prefix = "team1-video-project-"
}

# ECR 리포지토리 (GitHub Actions와 이름 일치)
resource "aws_ecr_repository" "docker_repo" {
  name         = "team1-images"
  force_delete = true
}

# RDS (PostgreSQL) - AZ 1개에 고정
resource "aws_db_instance" "default" {
  allocated_storage    = 20
  db_name              = "videodb"
  engine               = "postgres"
  engine_version       = "15"
  instance_class       = "db.t3.micro"
  username             = "postgres"
  password             = var.db_password
  skip_final_snapshot  = true
  publicly_accessible  = false
  
  # AZ 고정
  availability_zone    = "${var.aws_region}a"
  
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
}

resource "aws_db_subnet_group" "default" {
  name       = "rds-subnet-group"
  subnet_ids = module.vpc.private_subnets
}