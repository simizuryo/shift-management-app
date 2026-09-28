# EC2単一インスタンス(ステップ1)。
# 無料利用枠の対象になるt3.microを1台だけ作る。ALB・ECSは無料利用枠がないため使わない。
# この段階ではDockerを入れて仮のページ(nginx)を返すだけにし、アプリのデプロイはステップ3で行う。

# 最新のAmazon Linux 2023(標準版。SSM Agent同梱)のAMI ID。AWSが公開しているSSMパラメータから取得する
data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# SSM Session Managerで接続するためのIAMロール(SSHキー不要)
resource "aws_iam_role" "ec2" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2.name
}

resource "aws_instance" "app" {
  ami                    = data.aws_ssm_parameter.al2023_ami.value
  instance_type          = var.ec2_instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  # IMDSv2を必須にし、メタデータサービス経由の認証情報窃取(SSRF等)を防ぐ
  metadata_options {
    http_tokens = "required"
  }

  # EBSの無料利用枠(30GB)に収まるサイズにする
  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  user_data                   = file("${path.module}/templates/user_data.sh")
  user_data_replace_on_change = true

  tags = {
    Name = "${var.project_name}-app"
  }

  # AMIの更新で意図せずインスタンスが作り直されないようにする
  lifecycle {
    ignore_changes = [ami]
  }
}
