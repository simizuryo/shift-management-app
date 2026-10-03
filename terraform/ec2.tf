# EC2単一インスタンス(ステップ1)。
# 無料利用枠の対象になるt3.microを1台だけ作る。ALB・ECSは無料利用枠がないため使わない。
# 起動時にDocker・デプロイスクリプト・nginxの設定を用意し、仮のページ(nginx)を返す。
# アプリはECRにイメージをpushしたあと、デプロイスクリプトで起動する(ステップ3、README参照)。

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

  user_data = templatefile("${path.module}/templates/user_data.sh.tftpl", {
    nginx_conf = file("${path.module}/templates/nginx.conf")
    deploy_script = templatefile("${path.module}/templates/deploy-app.sh.tftpl", {
      region                  = var.aws_region
      registry                = split("/", aws_ecr_repository.app["backend"].repository_url)[0]
      backend_repository_url  = aws_ecr_repository.app["backend"].repository_url
      frontend_repository_url = aws_ecr_repository.app["frontend"].repository_url
      db_secret_arn           = aws_db_instance.main.master_user_secret[0].secret_arn
      db_host                 = aws_db_instance.main.address
      db_name                 = aws_db_instance.main.db_name
      db_username             = aws_db_instance.main.username
    })
  })
  user_data_replace_on_change = true

  tags = {
    Name = "${var.project_name}-app"
  }

  # AMIの更新で意図せずインスタンスが作り直されないようにする
  lifecycle {
    ignore_changes = [ami]
  }
}
