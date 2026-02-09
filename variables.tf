variable "aws_region" {
  description = "서울 리전 고정"
  default     = "ap-northeast-2"
}

variable "cluster_name" {
  default     = "team1-rosa-cluster"
}

variable "enable_ai_worker" {
  description = "AI Worker(GPU) 활성화 여부"
  type        = bool
  default     = false 
}

variable "db_password" {
  description = "RDS 비밀번호"
  type        = string
  sensitive   = true
}

# [수정] 4.15.59 (EOL) -> 4.17.47 (최신 안정 버전)
variable "rosa_version" {
  default = "4.17.47"
}