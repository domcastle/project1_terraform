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
provider "rhcs" {
  token = "eyJhbGciOiJIUzUxMiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI0NzQzYTkzMC03YmJiLTRkZGQtOTgzMS00ODcxNGRlZDc0YjUifQ.eyJpYXQiOjE3NzAyNjE0MTEsImp0aSI6IjhhM2UwYjFmLThjYTQtNGFkMi1iMjEzLWY5ZWQ0YWYxZTY1YSIsImlzcyI6Imh0dHBzOi8vc3NvLnJlZGhhdC5jb20vYXV0aC9yZWFsbXMvcmVkaGF0LWV4dGVybmFsIiwiYXVkIjoiaHR0cHM6Ly9zc28ucmVkaGF0LmNvbS9hdXRoL3JlYWxtcy9yZWRoYXQtZXh0ZXJuYWwiLCJzdWIiOiJmOjUyOGQ3NmZmLWY3MDgtNDNlZC04Y2Q1LWZlMTZmNGZlMGNlNjpjYXB0MTk5OSIsInR5cCI6Ik9mZmxpbmUiLCJhenAiOiJjbG91ZC1zZXJ2aWNlcyIsIm5vbmNlIjoiNmU1YTU5MGUtMDVkZi00MzBlLWIwMjYtZTNhN2I4NjIyNjcwIiwic2lkIjoiMTQyMjA0MmMtNjNlMS00MzBiLWIwNGMtNDk5ZGI5YjVhY2NmIiwic2NvcGUiOiJvcGVuaWQgYmFzaWMgcm9sZXMgd2ViLW9yaWdpbnMgY2xpZW50X3R5cGUucHJlX2tjMjUgb2ZmbGluZV9hY2Nlc3MifQ.YCGM5iyozp5i9AoIKjBXn01SFFeoG9nLKEXsr_zik44mHgIacyE7cUHrJOpmnYJeX7m9nCqntR3o_16EHBfYUQ"
}

data "aws_caller_identity" "current" {}