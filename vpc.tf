module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  # 이미지상의 이름인 'justic-vpc'로 변경
  name = "justic-vpc" 
  cidr = "10.0.0.0/16"

  # 이미지에서 확인된 ap-northeast-2a와 2c 사용
  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  
  # 이미지의 인스턴스가 10.0.2.47 IP를 쓰고 있으므로 
  # private 서브넷 대역을 유지하거나 포함해야 합니다.
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
