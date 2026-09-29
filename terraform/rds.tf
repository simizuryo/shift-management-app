# RDS PostgreSQL(ステップ2)。
# 無料利用枠の対象になるdb.t4g.micro・ストレージ20GB・シングルAZで1台だけ作る。
# プライベートサブネットに置き、パブリックアクセスは無効にする。接続できるのはEC2だけ(security_groups.tf参照)。

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [for s in aws_subnet.private : s.id]

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier     = "${var.project_name}-db"
  engine         = "postgres"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  # ストレージは無料利用枠(20GB)に収め、自動拡張もしない
  allocated_storage     = 20
  max_allocated_storage = 0
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  # マスターパスワードはRDSが生成してSecrets Managerに保存する。tfstateに平文で残さないため
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  availability_zone      = var.availability_zone
  multi_az               = false
  publicly_accessible    = false

  # 課題の検証用で、セッションごとにapply/destroyするため、バックアップと削除保護は無効にする
  backup_retention_period  = 0
  deletion_protection      = false
  skip_final_snapshot      = true
  delete_automated_backups = true

  # マイナーバージョンの自動更新で意図しない差分が出ないよう、更新は手動で行う
  auto_minor_version_upgrade = false
  apply_immediately          = true

  tags = {
    Name = "${var.project_name}-db"
  }
}

# EC2からDBのマスターパスワード(Secrets Manager)を読めるようにする。
# パスワードをSSMのコマンド履歴などに残さず、インスタンス上で取得するため
resource "aws_iam_role_policy" "ec2_read_db_secret" {
  name = "${var.project_name}-read-db-secret"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "secretsmanager:GetSecretValue"
      Resource = aws_db_instance.main.master_user_secret[0].secret_arn
    }]
  })
}
