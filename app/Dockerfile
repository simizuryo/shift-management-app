# syntax=docker/dockerfile:1
# 本番用(AWS の EC2 上で動かす)イメージ。ローカル開発は npm run dev を使う。
#
#   docker build -t shift-frontend .
#   docker run -p 3000:3000 -e API_INTERNAL_URL=http://backend:3000 shift-frontend

FROM node:22-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

FROM node:22-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
# ブラウザから呼ぶ API の URL。ビルド時にクライアントの JS に埋め込まれる。
# 本番は nginx が /api/* を Rails に振り分けるため、相対パスの /api にする(パブリック IP が変わっても再ビルド不要)
ARG NEXT_PUBLIC_API_BASE_URL=/api
ENV NEXT_PUBLIC_API_BASE_URL=${NEXT_PUBLIC_API_BASE_URL} \
    NEXT_TELEMETRY_DISABLED=1
RUN npm run build

FROM node:22-alpine
WORKDIR /app
ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    PORT=3000 \
    HOSTNAME=0.0.0.0
COPY --from=build /app/public ./public
COPY --from=build --chown=node:node /app/.next/standalone ./
COPY --from=build --chown=node:node /app/.next/static ./.next/static
USER node
EXPOSE 3000
CMD ["node", "server.js"]
