# Terraform(AWS 環境)

シフト管理アプリを AWS 上で動かすための Terraform コード。課題提出用のため、**無料利用枠の範囲に限定した最小構成**にしている。

一気に作らず、次の順で段階的に進める。

| ステップ | 内容 | 状態 |
|---|---|---|
| 1 | ネットワーク + EC2(Docker と仮ページの nginx) | ✅ このディレクトリ |
| 2 | RDS(EC2 からのみ接続できるプライベートサブネットに置く) | 未着手 |
| 3 | デプロイ(アプリのコンテナを EC2 上で動かす) | 未着手 |

## 構成(ステップ1)

```
インターネット
   │ HTTP(80) のみ許可
   ▼
VPC 10.0.0.0/16
 └─ パブリックサブネット 10.0.0.0/24 (ap-northeast-1a)
     └─ EC2 t3.micro (Amazon Linux 2023, パブリックIPは自動割り当て)
         └─ Docker: nginx(仮ページ) :80
```

- 接続は **SSM Session Manager** で行う。SSH キーは作らず、22 番ポートも開けない
- IMDSv2 を必須にしている
- ALB / NAT Gateway / ECS / Elastic IP は無料利用枠がない、または不要なため使わない

## 前提

- Terraform 1.7 以上
- AWS CLI で認証済み(`aws sts get-caller-identity` が通ること)
- (任意)対話的に接続するなら [Session Manager プラグイン](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)

## 作成する

```powershell
cd terraform
terraform init
terraform plan      # 作成されるリソースを確認(10 個)
terraform apply
```

出力される `app_url` をブラウザで開き、「Welcome to nginx!」が表示されれば OK(起動処理に 30 秒〜1 分ほどかかる)。

## 動作確認

```powershell
# SSM でコマンドを実行する(プラグイン不要)
aws ssm send-command --region ap-northeast-1 `
  --instance-ids <instance_id> `
  --document-name AWS-RunShellScript `
  --parameters 'commands=["docker ps"]'

# 対話的に接続する(Session Manager プラグインが必要)
aws ssm start-session --region ap-northeast-1 --target <instance_id>
```

Git Bash から `send-command` を実行する場合は、`/usr/...` のような Unix パスが書き換えられないよう `MSYS_NO_PATHCONV=1` を付ける。

## コストの目安(東京リージョン)

| リソース | 料金 | 備考 |
|---|---|---|
| EC2 t3.micro | 約 $0.0136/時間(月 約$10) | 無料利用枠の対象 |
| EBS gp3 8GB | 約 $0.77/月 | 無料利用枠(30GB)の範囲内 |
| パブリック IPv4 | 約 $0.005/時間(月 約$3.6) | **無料利用枠なし** |
| VPC / サブネット / IGW / SG / IAM | $0 | |

- 1 時間あたり約 $0.02。動作確認を数時間するだけなら数セント程度
- 2025 年 7 月以降に作成したアカウントは、クレジットを消費する「FREE プラン」になる。FREE プランのままなら実費の請求はなく、使った分がクレジットから差し引かれる(残高は Billing コンソールの「Free Tier」で確認できる)
- 起動している時間だけ課金されるため、**使い終わったら必ず削除する**

## 削除する

```powershell
terraform plan -destroy   # 削除されるリソースを確認
terraform destroy
```

削除後、EC2 コンソールでインスタンスが「終了済み」になっていることを確認する。次回また `terraform apply` すれば同じ構成が再現される。
