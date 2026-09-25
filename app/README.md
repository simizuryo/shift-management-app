# シフト管理アプリ フロントエンド(Next.js)

## 起動手順

1. バックエンド(Rails API)を起動する。手順は [backend/README.md](../backend/README.md) を参照(`http://localhost:3001` で待ち受け)
2. このディレクトリで開発サーバーを起動する

   ```bash
   npm run dev
   ```

3. http://localhost:3000 を開く

## API の接続先

既定では `http://localhost:3001` の Rails API を呼び出す。変更する場合は `.env.local` に以下を設定する。

```
NEXT_PUBLIC_API_BASE_URL=http://localhost:3001
```

API 呼び出しは `lib/shiftsApi.js` にまとめている。

---

This is a [Next.js](https://nextjs.org) project bootstrapped with [`create-next-app`](https://nextjs.org/docs/app/api-reference/cli/create-next-app).

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `app/page.js`. The page auto-updates as you edit the file.

This project uses [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts) to automatically optimize and load [Geist](https://vercel.com/font), a new font family for Vercel.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.
