terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    rhcs = {
      source  = "terraform-redhat/rhcs"
      version = ">= 1.6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 로컬에 설정된 OCM 토큰을 사용합니다. (사전에 `rosa login` 필요)

data "aws_caller_identity" "current" {}