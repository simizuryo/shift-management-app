# シフト管理アプリ バックエンド(Rails API)

Ruby on Rails 8.1(APIモード)+ SQLite。Windows に Ruby をインストールせず、Docker の公式 Ruby イメージで実行する(追加費用なし)。

## 前提

- Docker Desktop が起動していること
- 以下のコマンドはこの `backend/` ディレクトリで PowerShell から実行する
- gem は Docker ボリューム `shift_bundle` にキャッシュされる(2回目以降の起動が速くなる)

## セットアップ(初回のみ)

```powershell
docker run --rm -v "${PWD}:/app" -v shift_bundle:/usr/local/bundle -w /app ruby:3.3.12 bash -c "bundle install && bin/rails db:prepare"
```

## サーバー起動

Next.js が 3000 番を使うため、ホスト側は 3001 番で公開する。

```powershell
docker run --rm -it -p 3001:3000 -v "${PWD}:/app" -v shift_bundle:/usr/local/bundle -w /app ruby:3.3.12 bash -c "rm -f tmp/pids/server.pid && bin/rails s -b 0.0.0.0"
```

- `rm -f tmp/pids/server.pid` は、コンテナ内のPIDが毎回1になり前回の pid ファイルと衝突して起動に失敗するのを防ぐため
- 動作確認: http://localhost:3001/shifts

## テスト

```powershell
docker run --rm -v "${PWD}:/app" -v shift_bundle:/usr/local/bundle -w /app ruby:3.3.12 bin/rails test
```

## API

| メソッド | パス | 説明 |
|---|---|---|
| GET | `/shifts` | シフトを日付・開始時刻の昇順で全件返す |
| POST | `/shifts` | シフトを1件登録する |
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
