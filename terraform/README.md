# Terraform(AWS 環境)

シフト管理アプリを AWS 上で動かすための Terraform コード。課題提出用のため、**無料利用枠の範囲に限定した最小構成**にしている。

一気に作らず、次の順で段階的に進める。

| ステップ | 内容 | 状態 |
|---|---|---|
| 1 | ネットワーク + EC2(Docker と仮ページの nginx) | ✅ このディレクトリ |
| 2 | RDS PostgreSQL(EC2 からのみ接続できるプライベートサブネットに置く) | ✅ このディレクトリ |
| 3 | デプロイ(ECR にイメージを置き、アプリのコンテナを EC2 上で動かす) | ✅ このディレクトリ |

## 構成

```
インターネット
   │ HTTP(80) のみ許可
   ▼
VPC 10.0.0.0/16
 ├─ パブリックサブネット 10.0.0.0/24 (ap-northeast-1a)
 │   └─ EC2 t3.micro (Amazon Linux 2023, パブリックIPは自動割り当て)
 │       └─ Docker(ネットワーク shift-app)
 │           ├─ web: nginx :80 ── /api/* ──▶ backend: Rails :3000
 │           │                └─ それ以外 ─▶ frontend: Next.js :3000 ── サーバー側の API 呼び出し ─▶ backend
 │           └─ backend ── PostgreSQL(5432) ※EC2 の SG からのみ許可
 │                  │
 │                  ▼
 └─ プライベートサブネット 10.0.10.0/24 (1a) / 10.0.11.0/24 (1c)  ※インターネットへの経路なし
     └─ RDS PostgreSQL 17 db.t4g.micro (シングルAZ, 1a に配置)

ECR: shift-management-app/backend, shift-management-app/frontend(手元でビルドして push、EC2 は pull するだけ)
```

- nginx が `/api/*` を Rails に、それ以外を Next.js に振り分ける。画面の `/shifts/new` などと API の `/shifts/:id` のパスが重なるため、API には `/api` を付けて区別している。画面と API が同じオリジンになるので CORS は不要で、パブリック IP が変わってもイメージの再ビルドは要らない
- 外に公開しているのは nginx の 80 番だけで、Next.js・Rails の 3000 番には外から届かない
- nginx の設定は `templates/nginx.conf`、デプロイスクリプトは `templates/deploy-app.sh.tftpl`。どちらも EC2 の起動時(user_data)に `/etc/shift-app/nginx.conf` と `/usr/local/bin/deploy-app.sh` に置かれる

- 接続は **SSM Session Manager** で行う。SSH キーは作らず、22 番ポートも開けない
- IMDSv2 を必須にしている
- ALB / NAT Gateway / ECS / Elastic IP は無料利用枠がない、または不要なため使わない
- RDS はパブリックアクセスを無効にしている。DB サブネットグループの要件でプライベートサブネットを 2 AZ 分作るが、RDS 自体はシングルAZ
- RDS のマスターパスワードは RDS が生成して **Secrets Manager** に保存する(`manage_master_user_password`)。tfstate には平文で残らない。EC2 のロールにはこのシークレットの読み取り権限だけを付けている
- 検証用のため、RDS のバックアップ保持は 0 日、削除保護なし、destroy 時の最終スナップショットなし。**destroy すると DB のデータは消える**
- Rails の DB パスワードは、デプロイのたびに EC2 上で Secrets Manager から取り出し、root だけが読める `/etc/shift-app/backend.env` に書く(RDS が管理するシークレットは定期的にローテーションされるため、毎回取り直す)
- t3.micro はメモリが 1GB しかないため、起動時に 1GB のスワップを作る

## 前提

- Terraform 1.7 以上
- AWS CLI で認証済み(`aws sts get-caller-identity` が通ること)
- Docker Desktop が起動していること(イメージのビルドと push に使う)
- (任意)対話的に接続するなら [Session Manager プラグイン](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)

## 作成する

```powershell
cd terraform
terraform init
terraform plan      # 作成されるリソースを確認(24 個)
terraform apply
```

EC2 のデプロイスクリプトが RDS の情報を使うため、EC2 は RDS ができてから作られる。全体で 6〜7 分ほどかかる。この時点で出力される `app_url` を開くと、仮ページ「Welcome to nginx!」が表示される(起動処理に 1 分ほどかかる)。

## デプロイする

リポジトリのルートで PowerShell から実行する。ECR のリポジトリも apply/destroy のたびに作り直すため、**apply したら毎回イメージを push し直す**。コードを変更したときも同じ手順でよい。

```powershell
# 1. ECR にログインする
$registry = terraform -chdir=terraform output -raw ecr_registry
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin $registry

# 2. イメージをビルドして push する
docker build -t "$registry/shift-management-app/backend:latest" backend
docker build -t "$registry/shift-management-app/frontend:latest" app
docker push "$registry/shift-management-app/backend:latest"
docker push "$registry/shift-management-app/frontend:latest"

# 3. EC2 上でデプロイスクリプトを実行する(ECR から pull してコンテナを入れ替える)
$instanceId = terraform -chdir=terraform output -raw instance_id
$commandId = aws ssm send-command --region ap-northeast-1 --instance-ids $instanceId `
  --document-name AWS-RunShellScript --timeout-seconds 600 `
  --parameters 'commands=["/usr/local/bin/deploy-app.sh"]' `
  --query Command.CommandId --output text

# 4. 結果を見る(Status が InProgress の間は少し待って再実行する。最後に「OK: アプリが起動した」と出れば成功)
aws ssm get-command-invocation --region ap-northeast-1 --command-id $commandId --instance-id $instanceId `
  --query "[Status,StandardOutputContent,StandardErrorContent]" --output text
```

`app_url` を開き、シフト管理アプリの画面が表示されれば OK。Rails は起動時に `db:prepare` を実行するので、初回デプロイで RDS にテーブルが作られる。

うまく動かないときは、EC2 上で `docker ps -a`、`docker logs backend`、`docker logs frontend`、`docker logs web` を確認する。

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

### RDS への接続確認

EC2 上でシークレットからパスワードを取り出し、`postgres` イメージの psql で接続する。パスワードはインスタンス上でだけ扱い、SSM のコマンド履歴には残さない。

```bash
# EC2 上(aws ssm start-session で接続したシェル)で実行する
SECRET_ARN=<db_master_secret_arn>
DB_HOST=<db_endpoint>
PW=$(aws secretsmanager get-secret-value --region ap-northeast-1 --secret-id "$SECRET_ARN" \
  --query SecretString --output text | python3 -c 'import json,sys; print(json.load(sys.stdin)["password"])')
sudo docker run --rm -e PGPASSWORD="$PW" public.ecr.aws/docker/library/postgres:17 \
  psql "host=$DB_HOST user=shift_admin dbname=shift_management_production sslmode=require" -c 'SELECT version();'
```

PostgreSQL のバージョンが表示されれば OK。手元の PC からは `db_endpoint` にはつながらない(プライベートサブネット+SG で遮断)。

## コストの目安(東京リージョン)

| リソース | 料金 | 備考 |
|---|---|---|
| EC2 t3.micro | 約 $0.0136/時間(月 約$10) | 無料利用枠の対象 |
| EBS gp3 8GB | 約 $0.77/月 | 無料利用枠(30GB)の範囲内 |
| RDS db.t4g.micro(シングルAZ) | 約 $0.025/時間(月 約$18) | 無料利用枠の対象 |
| RDS ストレージ gp3 20GB | 約 $2.8/月 | 無料利用枠(20GB)の範囲内 |
| Secrets Manager(シークレット 1 件) | $0.40/月(日割り) | |
| ECR の保管(2 イメージで約 0.2GB) | $0.10/GB-月(月 約$0.02) | 無料利用枠(500MB)の範囲内。同じリージョンの EC2 への転送は無料 |
| パブリック IPv4 | 約 $0.005/時間(月 約$3.6) | **無料利用枠なし** |
| VPC / サブネット / IGW / ルートテーブル / SG / IAM | $0 | |

- 1 時間あたり約 $0.05(EC2 分 約 $0.02 + RDS 分 約 $0.03)。動作確認を数時間するだけなら数セント程度
- 2025 年 7 月以降に作成したアカウントは、クレジットを消費する「FREE プラン」になる。FREE プランのままなら実費の請求はなく、使った分がクレジットから差し引かれる(残高は Billing コンソールの「Free Tier」で確認できる)
- 起動している時間だけ課金されるため、**使い終わったら必ず削除する**

## 削除する

```powershell
terraform plan -destroy   # 削除されるリソースを確認
terraform destroy
```

削除後、EC2 コンソールでインスタンスが「終了済み」に、RDS コンソールでデータベースが消えていることを確認する。ECR のリポジトリはイメージごと削除される(`force_delete`)。次回また `terraform apply` すれば同じ構成が再現される。
