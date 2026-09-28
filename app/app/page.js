import Link from "next/link";
import { fetchShifts } from "@/lib/shiftsApi";
import { parseMonth } from "@/lib/calendar";
import ShiftCalendar from "./ShiftCalendar";
import ShiftList from "./ShiftList";
import { fromCalendarQuery } from "./shifts/backTarget";
import styles from "./page.module.css";

// 表示形式は ?view=list(既定)/ ?view=calendar、カレンダーの月は ?month=YYYY-MM で指定する。
// searchParams を使うため、このページはリクエストごとに描画され、常に最新のシフトを表示する。
export default async function ShiftListPage({ searchParams }) {
  const { view, month } = await searchParams;
  const isCalendar = view === "calendar";
  const calendarMonth = parseMonth(month);

  let shifts = [];
  let loadError = "";
  try {
    shifts = await fetchShifts();
  } catch {
    loadError = "シフト一覧を取得できませんでした。バックエンド(Rails API)が起動しているか確認してください。";
  }

  return (
    <div className={styles.page}>
      <header className={styles.header}>
        <h1 className={styles.title}>シフト管理アプリ</h1>
      </header>

      <main className={styles.main}>
        <div className={styles.toolbar}>
          <nav className={styles.viewToggle} aria-label="表示切り替え">
            <Link
              href="/"
              className={`${styles.viewToggleItem} ${isCalendar ? "" : styles.viewToggleActive}`}
              aria-current={isCalendar ? undefined : "page"}
            >
              一覧
            </Link>
            <Link
              href="/?view=calendar"
              className={`${styles.viewToggleItem} ${isCalendar ? styles.viewToggleActive : ""}`}
              aria-current={isCalendar ? "page" : undefined}
            >
              カレンダー
            </Link>
          </nav>
          <Link
            href={isCalendar ? `/shifts/new?${fromCalendarQuery(calendarMonth)}` : "/shifts/new"}
            className={styles.newButton}
          >
            + 新規登録
          </Link>
        </div>

        {loadError ? (
          <p className={styles.errorState}>{loadError}</p>
        ) : isCalendar ? (
          <ShiftCalendar shifts={shifts} month={calendarMonth} />
        ) : (
          <ShiftList shifts={shifts} />
        )}
      </main>
    </div>
  );
}
