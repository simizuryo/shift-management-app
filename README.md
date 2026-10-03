# シフト管理アプリ

シフト(勤務予定)を登録・閲覧・編集・削除できるシンプルな Web アプリ。プログラミング学習の課題として、CRUD 処理・データ設計・画面設計から AWS へのデプロイまでを一通り実装した。

- 利用者は開発者本人の 1 人を想定し、認証やユーザー管理は持たない
- 要件の詳細は [docs/requirements.md](docs/requirements.md)、画面設計は [docs/screen-design.md](docs/screen-design.md) を参照

## 目次

- [機能](#機能)
- [起動手順](#起動手順)
- [使い方](#使い方)
- [構成](#構成)

## 機能

| 機能 | 内容 |
|---|---|
| 一覧表示 | 登録済みのシフトを全件、日付・開始時刻の昇順で表示する |
| カレンダー表示 | 日曜始まりの月カレンダーで表示する。前月・翌月・今月に移動でき、その月の合計勤務時間も表示する |
| 登録 | 日付・開始時刻・終了時刻・メモを入力して登録する |
| 編集 | 専用の編集画面で、登録済みの内容を 1 件ずつ編集する |
| 削除 | 一覧から 1 件ずつ削除する。削除前に確認ダイアログを表示する |

### 詳しい仕様

- **表示の切り替え**: トップ画面の「一覧 / カレンダー」で切り替える。表示形式と月は URL(`/?view=calendar&month=YYYY-MM`)に保持するので、再読み込みやブラウザの「戻る」でも表示が変わらない
- **カレンダー**: 各日のマスに「開始時刻-終了時刻」とメモを表示する。今日のマスを強調し、日曜は赤、土曜は青で表示する。長いメモは省略され、マウスを乗せると全文が出る
- **入力チェック**: 日付・開始時刻・終了時刻は必須で、終了時刻は開始時刻より後でなければならない。メモは任意。画面とAPIの両方でチェックし、エラーはフォームの下に表示する
- **戻り先**: 登録・編集画面の「戻る」「キャンセル」、および保存後の遷移先は、画面を開く前に見ていた表示になる(一覧から開いたら一覧、カレンダーから開いたらそのカレンダーの月)
- **存在しないシフト**: 存在しない ID の編集画面を開くと 404 ページを表示する

## 起動手順

ローカルで動かす手順。Ruby や PostgreSQL を PC に直接インストールせず、Docker の公式イメージで動かす。

### 前提

| ソフト | 用途 |
|---|---|
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | Rails API と PostgreSQL を動かす(起動しておくこと) |
| [Node.js](https://nodejs.org/) 20.9 以上 | Next.js を動かす |
| Git | リポジトリの取得 |

### 1. リポジトリを取得する

```powershell
git clone https://github.com/simizuryo/shift-management-app.git
cd shift-management-app
```

### 2. バックエンド(Rails API + PostgreSQL)を起動する

```powershell
cd backend
docker compose up
```

- 初回は gem のインストールに数分かかる。DB の作成とテーブルの作成(`db:prepare`)も起動時に自動で行う
- `Listening on http://0.0.0.0:3000` と表示されたら起動完了。ホスト側は **3001 番**で公開している
- 確認: http://localhost:3001/shifts を開いて `[]`(シフトが 0 件)が返れば OK

### 3. フロントエンド(Next.js)を起動する

別のターミナルを開いて実行する。

```powershell
cd app
npm install   # 初回のみ
npm run dev
```

http://localhost:3000 を開くと、アプリのトップ画面が表示される。

### 停止する

- フロントエンド: `npm run dev` のターミナルで `Ctrl+C`
- バックエンド: `docker compose up` のターミナルで `Ctrl+C` を押したあと、`backend/` で `docker compose down` を実行する
- DB のデータも消す場合は `docker compose down -v`

### テストを実行する

```powershell
cd backend
docker compose run --rm web bin/rails test
```

### 補足

- API の接続先は環境変数 `NEXT_PUBLIC_API_BASE_URL` で変えられる(既定は `http://localhost:3001`)。詳しくは [app/README.md](app/README.md)
- バックエンドの設定(DB の環境変数、API の詳細)は [backend/README.md](backend/README.md)
- AWS へのデプロイ手順は [terraform/README.md](terraform/README.md)

## 使い方

### シフトを登録する

1. トップ画面右上の「+ 新規登録」を押す
2. 日付・開始時刻・終了時刻を入力する。メモは任意(例: 「レジ対応」)
3. 「登録する」を押すと、元の画面に戻り、登録したシフトが表示される

### シフトを確認する

- **一覧で見る**: トップ画面の「一覧」を選ぶと、全シフトが日付順に並ぶ
- **カレンダーで見る**: 「カレンダー」を選ぶと月表示になる
  - 「‹」で前月、「›」で翌月、「今月」で今日を含む月に移動する
  - カレンダーの上部に、その月の合計勤務時間とシフトの件数が表示される

### シフトを編集する

1. 一覧では行の「編集」を、カレンダーではシフトをクリックする
2. 編集画面で内容を変更し、「更新する」を押す
3. 編集を開いた元の画面(一覧、またはカレンダーのその月)に戻る

変更をやめるときは「キャンセル」または左上の「← 一覧へ戻る / カレンダーへ戻る」を押す。

### シフトを削除する

1. 一覧で、削除したい行の「削除」を押す
2. 「2026/09/25 09:00-17:00 のシフトを削除しますか?」という確認が出るので「OK」を押す
3. 一覧から消える(「キャンセル」なら何もしない)

## 構成

### 技術スタック

| 区分 | 使用技術 |
|---|---|
| フロントエンド | Next.js 16(App Router)、React 19 |
| バックエンド | Ruby on Rails 8.1(API モード)、Ruby 3.3 |
| データベース | PostgreSQL 17 |
| 実行環境 | Docker(ローカル・AWS とも) |
| インフラ | AWS(EC2・RDS・ECR)を Terraform で構築 |

### ローカルの構成

```
ブラウザ ──▶ Next.js :3000 ──(API 呼び出し)──▶ Rails API :3001 ──▶ PostgreSQL :5432
                                                  └──── Docker Compose(backend/compose.yaml)────┘
```

- フロントエンドとバックエンドを分け、Next.js から Rails の REST API を呼び出す
- 一覧・編集画面のデータはサーバー側(Server Components)で取得して描画し、登録・更新・削除はブラウザから API を呼び出す

### AWS の構成

```
インターネット
   │ HTTP(80)
   ▼
EC2 t3.micro(パブリックサブネット)
 └─ Docker
     ├─ nginx :80 ─┬─ /api/* ──▶ Rails API
     │             └─ それ以外 ─▶ Next.js
     └─ Rails API ──▶ RDS PostgreSQL 17(プライベートサブネット、EC2 からのみ接続可)

ECR: 手元でビルドしたイメージを push し、EC2 が pull して起動する
```

- 画面と API を同じ EC2 の nginx で振り分けるので、ブラウザから見て同じオリジンになり CORS が不要
- 接続は SSM Session Manager で行い、SSH のポートは開けない。DB のパスワードは Secrets Manager で管理する
- 無料利用枠の範囲で構成し、費用を抑えるため使うときだけ apply し、終わったら destroy する
- 詳しくは [terraform/README.md](terraform/README.md) を参照

### API

| メソッド | パス | 説明 |
|---|---|---|
| GET | `/shifts` | シフトを日付・開始時刻の昇順で全件返す |
| POST | `/shifts` | シフトを 1 件登録する |
| GET | `/shifts/:id` | シフトを 1 件返す |
| PATCH | `/shifts/:id` | シフトを 1 件更新する |
| DELETE | `/shifts/:id` | シフトを 1 件削除する |

AWS では nginx を通すため、パスの先頭に `/api` が付く(例: `/api/shifts`)。ステータスコードなどの詳細は [backend/README.md](backend/README.md) を参照。

### データモデル

`shifts` テーブル 1 つだけ。

| カラム | 型 | 必須 | 説明 |
|---|---|---|---|
| `id` | bigint | ○ | 主キー |
| `date` | date | ○ | 勤務日 |
| `start_time` | time | ○ | 開始時刻 |
| `end_time` | time | ○ | 終了時刻(開始時刻より後) |
| `memo` | string | | メモ |
| `created_at` / `updated_at` | datetime | ○ | 作成・更新日時 |

### ディレクトリ構成

```
.
├── app/        フロントエンド(Next.js)
│   ├── app/    画面(page.js)とコンポーネント
│   └── lib/    API 呼び出し(shiftsApi.js)、勤務時間の計算(workHours.js)
├── backend/    バックエンド(Rails API)
│   ├── app/    モデル(Shift)とコントローラー(ShiftsController)
│   ├── db/     マイグレーションとスキーマ
│   └── test/   テスト
├── terraform/  AWS 環境(EC2・RDS・ECR)とデプロイ手順
└── docs/       要件定義・画面設計
```
