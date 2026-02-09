variable "aws_region" {
  description = "서울 리전 고정"
  default     = "ap-northeast-2"
}

variable "enable_ai_worker" {
  description = "AI Worker(GPU) 활성화 여부"
  type        = bool
  default     = false 
}