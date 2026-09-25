# Be sure to restart your server when you modify this file.

# Next.js 開発サーバーから Rails API を呼び出せるようにする。
# 許可するオリジンは環境変数 FRONTEND_ORIGIN で上書きできる。
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("FRONTEND_ORIGIN", "http://localhost:3000")

    resource "*",
      headers: :any,
      methods: [ :get, :post, :delete, :options, :head ]
  end
end
