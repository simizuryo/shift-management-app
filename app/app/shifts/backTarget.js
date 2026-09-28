import { calendarHref, formatMonth, parseMonth } from "@/lib/calendar";

// 登録・編集画面の戻り先は、開いた元の表示にする。
// カレンダーから開くときは、この関数で作ったクエリ(from=calendar&month=YYYY-MM)を付ける。
export function fromCalendarQuery(month) {
  return `from=calendar&month=${formatMonth(month)}`;
}

// 戻る・キャンセル・保存後の遷移先 { href, label }。
// クエリの値をそのまま URL に使わず、一覧かカレンダー(妥当な月)のどちらかに限って組み立てる。
export function backTarget({ from, month }) {
  if (from === "calendar") {
    return { href: calendarHref(formatMonth(parseMonth(month))), label: "カレンダーへ戻る" };
  }
  return { href: "/", label: "一覧へ戻る" };
}
