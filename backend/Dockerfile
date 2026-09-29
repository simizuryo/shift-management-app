# syntax=docker/dockerfile:1
# 本番用(AWS の EC2 上で動かす)イメージ。ローカル開発は compose.yaml を使う。
#
#   docker build -t shift-backend .
#   docker run -p 3000:3000 -e DB_HOST=... -e DB_PASSWORD=... -e SECRET_KEY_BASE=... shift-backend

ARG RUBY_VERSION=3.3.12
FROM ruby:${RUBY_VERSION}-slim AS base

WORKDIR /rails

# 実行時に必要なライブラリだけを入れる(libpq5: PostgreSQL クライアント)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libpq5 libyaml-0-2 tzdata && \
    rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test

# gem のビルドに必要なパッケージは、このステージにだけ入れる
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile -j 1 --gemfile

COPY . .
RUN bundle exec bootsnap precompile -j 1 app/ lib/

FROM base

# root 以外のユーザーで動かす
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build --chown=rails:rails /rails /rails
USER 1000:1000

EXPOSE 3000
# 起動のたびに db:prepare を実行し、DB の作成とマイグレーションを済ませてからサーバーを起動する
CMD ["bash", "-c", "bin/rails db:prepare && exec bin/rails server -b 0.0.0.0 -p 3000"]
