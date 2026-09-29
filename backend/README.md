# シフト管理アプリ バックエンド(Rails API)

Ruby on Rails 8.1(APIモード)+ PostgreSQL 17。Windows に Ruby や PostgreSQL をインストールせず、Docker の公式イメージで実行する(追加費用なし)。

## 前提

- Docker Desktop が起動していること
- 以下のコマンドはこの `backend/` ディレクトリで PowerShell から実行する
- `compose.yaml` で PostgreSQL(`db`)と Rails(`web`)をまとめて起動する
- DB のデータは Docker ボリューム `backend_pgdata`、gem は `backend_bundle` に保存される(2回目以降の起動が速くなる)

## サーバー起動

```powershell
docker compose up
```

- 起動時に `bundle install` と `bin/rails db:prepare` を実行するので、初回もこれだけでよい(初回は gem のインストールに数分かかる)
- Next.js が 3000 番を使うため、ホスト側は 3001 番で公開する
- 動作確認: http://localhost:3001/shifts
- 停止は `Ctrl+C` のあと `docker compose down`。DB のデータも消す場合は `docker compose down -v`

## テスト

```powershell
docker compose run --rm web bin/rails test
```

## データベースの接続設定

`config/database.yml` は接続先を環境変数で受け取る。ローカルでは `compose.yaml` で設定済み。

| 環境変数 | 既定値 | 説明 |
|---|---|---|
| `DB_HOST` | `localhost` | 接続先ホスト(ローカルは `db`、本番は RDS のエンドポイント) |
| `DB_PORT` | `5432` | |
| `DB_USERNAME` | `postgres` | |
| `DB_PASSWORD` | (なし) | |
| `DB_NAME` | `shift_management_production` | 本番のみ。開発・テストは `shift_management_development` / `shift_management_test` 固定 |
| `DB_SSLMODE` | `require` | 本番のみ。RDS は SSL 接続を強制している |

## API

| メソッド | パス | 説明 |
|---|---|---|
| GET | `/shifts` | シフトを日付・開始時刻の昇順で全件返す |
| POST | `/shifts` | シフトを1件登録する |
| GET | `/shifts/:id` | シフトを1件返す(存在しないID: `404 Not Found`) |
| PATCH | `/shifts/:id` | シフトを1件更新する(成功: `200 OK`、バリデーションエラー: `422`、存在しないID: `404`) |
| DELETE | `/shifts/:id` | シフトを1件削除する(成功: `204 No Content`、存在しないID: `404 Not Found`) |

### POST /shifts リクエスト例

```json
{ "shift": { "date": "2026-09-25", "start_time": "09:00", "end_time": "17:00", "memo": "レジ対応" } }
```

- 成功: `201 Created` と登録したシフト
- バリデーションエラー: `422 Unprocessable Content` と `{ "errors": ["..."] }`
  - date / start_time / end_time は必須、end_time は start_time より後であること

### レスポンス形式

```json
{ "id": 1, "date": "2026-09-25", "start_time": "09:00", "end_time": "17:00", "memo": "レジ対応" }
```

## CORS

`http://localhost:3000`(Next.js 開発サーバー)からのリクエストを許可している。変更する場合は環境変数 `FRONTEND_ORIGIN` を指定する。
