variable "project_name" {
  description = "リソース名のプレフィックスとして使う識別子"
  type        = string
  default     = "shift-management-app"
}

variable "aws_region" {
  description = "リソースを作成するAWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "vpc_cidr" {
  description = "VPCのCIDRブロック"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zone" {
  description = "EC2を置くパブリックサブネットのアベイラビリティゾーン"
  type        = string
  default     = "ap-northeast-1a"
}

variable "ec2_instance_type" {
  description = "EC2インスタンスタイプ(t3.microは無料利用枠の対象)"
  type        = string
  default     = "t3.micro"
}
