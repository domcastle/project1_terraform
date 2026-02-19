variable "aws_region" {
  description = "서울 리전 고정"
  default     = "ap-northeast-2"
}

variable "enable_ai_worker" {
  description = "AI Worker(GPU) 활성화 여부"
  type        = bool
  default     = false 
}

variable "target_vpc_name" {
  description = "Target VPC Name Tag"
  type        = string
  default     = "justic_vpc"
}

variable "target_subnet_name" {
  description = "Target Private Subnet Name Tag"
  type        = string
  default     = "justic_private_subnet_1"
}

variable "target_rt_name" {
  description = "Target Route Table Name Tag"
  type        = string
  default     = "justic_private_rt"
}

variable "nat_name" {
  description = "Existing NAT Gateway Name Tag"
  type        = string
  default = "justic_nat_gw" # 필요 시 기본값 설정
}