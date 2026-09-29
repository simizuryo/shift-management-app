output "instance_id" {
  description = "EC2のインスタンスID。aws ssm start-session --target で使う"
  value       = aws_instance.app.id
}

output "public_ip" {
  description = "EC2のパブリックIP(自動割り当て。インスタンスを停止・起動すると変わる)"
  value       = aws_instance.app.public_ip
}

output "app_url" {
  description = "動作確認用のURL"
  value       = "http://${aws_instance.app.public_ip}"
}

output "db_endpoint" {
  description = "RDSの接続先ホスト名(VPC内からのみ解決・接続できる)"
  value       = aws_db_instance.main.address
}

output "db_name" {
  description = "データベース名"
  value       = aws_db_instance.main.db_name
}

output "db_master_secret_arn" {
  description = "マスターユーザーの認証情報が入ったSecrets ManagerのARN"
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}
