/** @type {import('next').NextConfig} */
const nextConfig = {
  // Docker イメージを小さくするため、実行に必要なファイルだけを .next/standalone に出力する
  output: "standalone",
};

export default nextConfig;
