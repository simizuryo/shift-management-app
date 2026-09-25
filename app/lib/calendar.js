// 月表示カレンダー用の日付計算。日付は "YYYY-MM-DD"、月は "YYYY-MM" の文字列で扱う。
// タイムゾーンの影響を受けないよう、計算はすべて UTC の Date で行う。

const MONTH_PATTERN = /^(\d{4})-(0[1-9]|1[0-2])$/;

function pad(n) {
  return String(n).padStart(2, "0");
}

function toISODate(date) {
  return `${date.getUTCFullYear()}-${pad(date.getUTCMonth() + 1)}-${pad(date.getUTCDate())}`;
}

// 実行環境のローカル時刻での今日("YYYY-MM-DD")
export function todayISODate() {
  const now = new Date();
  return `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}`;
}

// "YYYY-MM" を { year, month(1〜12) } にする。不正な値や未指定なら今月にする
export function parseMonth(value) {
  const match = typeof value === "string" ? value.match(MONTH_PATTERN) : null;
  if (match) return { year: Number(match[1]), month: Number(match[2]) };

  const [year, month] = todayISODate().split("-").map(Number);
  return { year, month };
}

// { year, month } から delta ヶ月ずらした "YYYY-MM" を返す
export function addMonths({ year, month }, delta) {
  const date = new Date(Date.UTC(year, month - 1 + delta, 1));
  return `${date.getUTCFullYear()}-${pad(date.getUTCMonth() + 1)}`;
}

export function formatMonth({ year, month }) {
  return `${year}-${pad(month)}`;
}

// 日曜始まりの月カレンダーのマス目を週ごとの配列で返す。
// 前月・翌月の日も含めて週を埋め、各マスは { date, day, weekday, inMonth } とする。
export function buildMonthGrid({ year, month }) {
  const first = new Date(Date.UTC(year, month - 1, 1));
  const start = new Date(first);
  start.setUTCDate(1 - first.getUTCDay());

  const last = new Date(Date.UTC(year, month, 0));
  const end = new Date(last);
  end.setUTCDate(last.getUTCDate() + (6 - last.getUTCDay()));

  const weeks = [];
  for (const cursor = new Date(start); cursor <= end; cursor.setUTCDate(cursor.getUTCDate() + 1)) {
    if (cursor.getUTCDay() === 0) weeks.push([]);
    weeks[weeks.length - 1].push({
      date: toISODate(cursor),
      day: cursor.getUTCDate(),
      weekday: cursor.getUTCDay(),
      inMonth: cursor.getUTCMonth() === month - 1,
    });
  }
  return weeks;
}
