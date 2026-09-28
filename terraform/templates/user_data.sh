#!/bin/bash
# 初回起動時に実行する。Dockerを入れ、動作確認用の仮ページ(nginx)をポート80で返す。
# ステップ3(デプロイ)でアプリのコンテナに置き換える。
set -eu -o pipefail

dnf install -y docker
systemctl enable --now docker

# Docker Hubのレート制限を避けるため、ECR Publicの公式nginxイメージを使う
docker run -d --name placeholder --restart unless-stopped -p 80:80 public.ecr.aws/nginx/nginx:stable
