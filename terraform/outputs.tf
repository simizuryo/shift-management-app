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
