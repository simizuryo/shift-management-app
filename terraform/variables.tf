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

variable "private_subnet_azs" {
  description = "RDS用プライベートサブネットのアベイラビリティゾーン(DBサブネットグループの要件で2つ以上)"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "db_engine_version" {
  description = "PostgreSQLのバージョン(メジャーバージョンのみ指定すると、その時点のデフォルトのマイナーバージョンになる)"
  type        = string
  default     = "17"
}

variable "db_instance_class" {
  description = "RDSのインスタンスクラス(db.t4g.microは無料利用枠の対象)"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_name" {
  description = "作成するデータベース名"
  type        = string
  default     = "shift_management_production"
}

variable "db_username" {
  description = "RDSのマスターユーザー名"
  type        = string
  default     = "shift_admin"
}
