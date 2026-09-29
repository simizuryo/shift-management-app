# ネットワーク(ステップ1: EC2用のパブリックサブネット、ステップ2: RDS用のプライベートサブネット)
#
# EC2はパブリックサブネットに置き、自動割り当てのパブリックIPでインターネットと通信する。
# 外部からのインバウンドはセキュリティグループでHTTP(80)のみに制限する(security_groups.tf参照)。
# NAT Gatewayは無料利用枠がない(月$40前後)ため作らない。
# RDS用のプライベートサブネットはこのファイルの後半で定義する(ステップ2)。

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 0)
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-${var.availability_zone}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# プライベートサブネット(ステップ2: RDS用)
#
# RDSのDBサブネットグループは2つ以上のAZにまたがる必要があるため、2つ作る(RDS自体はシングルAZ)。
# インターネットへの経路(IGW・NAT Gateway)を持たないルートテーブルを関連付け、VPC内からしか届かないようにする。

resource "aws_subnet" "private" {
  for_each = { for i, az in var.private_subnet_azs : az => i }

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 10 + each.value)
  availability_zone = each.key

  tags = {
    Name = "${var.project_name}-private-${each.key}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
