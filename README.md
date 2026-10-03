# シフト管理アプリ

シフト(勤務予定)を登録・閲覧・編集・削除できるシンプルな Web アプリ。プログラミング学習の課題として、CRUD 処理・データ設計・画面設計から AWS へのデプロイまでを一通り実装した。

- 利用者は開発者本人の 1 人を想定し、認証やユーザー管理は持たない
- 要件の詳細は [docs/requirements.md](docs/requirements.md)、画面設計は [docs/screen-design.md](docs/screen-design.md) を参照

## 機能

| 機能 | 内容 |
|---|---|
| 一覧表示 | 登録済みのシフトを日付・開始時刻の順に表示する |
| カレンダー表示 | 月単位のカレンダーで表示する。前月・翌月に移動でき、その月の合計勤務時間も表示する |
| 登録 | 日付・開始時刻・終了時刻・メモを入力して登録する |
| 編集 | 専用の編集画面で 1 件ずつ編集する |
| 削除 | 一覧から 1 件ずつ削除する(削除前に確認あり) |

- 一覧とカレンダーはトップ画面で切り替える(`?view=calendar&month=YYYY-MM`)
- 登録・編集画面から戻ると、開く前に見ていた表示(一覧、またはカレンダーのその月)に戻る

## 画面

| パス | 画面 |
|---|---|
| `/` | トップ(一覧 / カレンダー) |
| `/shifts/new` | シフト登録 |
| `/shifts/[id]/edit` | シフト編集 |

## 技術スタック

| 区分 | 使用技術 |
|---|---|
| フロントエンド | Next.js 16(App Router)、React 19 |
| バックエンド | Ruby on Rails 8.1(API モード) |
| データベース | PostgreSQL 17 |
| ローカル実行環境 | Docker(Ruby・PostgreSQL は Docker の公式イメージで動かす) |
| インフラ | AWS(EC2・RDS・ECR)を Terraform で構築 |

## 構成

```
ブラウザ
   │
   ├─ 画面 ──▶ Next.js(サーバー側でも Rails API を呼び出して描画)
   │
   └─ API ──▶ Rails API ──▶ PostgreSQL
```

- フロントエンドとバックエンドを分け、Next.js から Rails の REST API(`/shifts`)を呼び出す
- AWS では EC2 上の nginx が `/api/*` を Rails に、それ以外を Next.js に振り分け、DB には RDS を使う。詳しくは [terraform/README.md](terraform/README.md) を参照

### データモデル

`shifts` テーブル 1 つだけ。

| カラム | 型 | 必須 | 説明 |
|---|---|---|---|
| `date` | date | ○ | 勤務日 |
| `start_time` | time | ○ | 開始時刻 |
| `end_time` | time | ○ | 終了時刻 |
| `memo` | string | | メモ |

## ディレクトリ構成

```
.
├── app/        フロントエンド(Next.js)
├── backend/    バックエンド(Rails API)
├── terraform/  AWS 環境(EC2・RDS・ECR)とデプロイ手順
└── docs/       要件定義・画面設計
```

## 起動・デプロイ手順

- ローカルで動かす: まず [backend/README.md](backend/README.md) の手順で Rails API と PostgreSQL を起動し(`docker compose up`、ポート 3001)、次に [app/README.md](app/README.md) の手順で Next.js を起動する(`npm run dev`、http://localhost:3000)
- AWS にデプロイする: [terraform/README.md](terraform/README.md) を参照。費用を抑えるため、使うときに apply し、終わったら destroy する運用にしている
