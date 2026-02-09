module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  # 이름 중복 방지를 위해 'sandbox' 접두어 사용
  name = "sandbox-ai-vpc" 
  
  # 기존 10.0.x.x와 겹치지 않게 10.1.x.x 대역 사용
  cidr = "10.1.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  
  # 서브넷 대역도 10.1.x.x로 변경
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets  = ["10.1.101.0/24", "10.1.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true # 비용 절약을 위해 NAT Gateway는 1개만 생성
  
  tags = {
    Terraform   = "true"
    Environment = "sandbox" # 환경 구분
    Project     = "AI-Worker-Test"
  }
}