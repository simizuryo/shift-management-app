import Link from "next/link";
import { addMonths, buildMonthGrid, calendarHref, formatMonth, todayISODate } from "@/lib/calendar";
import { formatDuration, summarizeMonth } from "@/lib/workHours";
import { fromCalendarQuery } from "./shifts/backTarget";
import styles from "./ShiftCalendar.module.css";

const WEEKDAYS = ["日", "月", "火", "水", "木", "金", "土"];

function weekdayClass(weekday) {
  if (weekday === 0) return styles.sunday;
  if (weekday === 6) return styles.saturday;
  return "";
}

// 月表示のシフトカレンダー(日曜始まり)。シフトをクリックすると編集画面へ移動する
export default function ShiftCalendar({ shifts, month }) {
  const today = todayISODate();
  const weeks = buildMonthGrid(month);
  const summary = summarizeMonth(shifts, formatMonth(month));

  // shifts は日付・開始時刻の昇順で渡されるので、日付ごとにまとめるだけで各日の並び順も保たれる
  const shiftsByDate = new Map();
  for (const shift of shifts) {
    if (!shiftsByDate.has(shift.date)) shiftsByDate.set(shift.date, []);
    shiftsByDate.get(shift.date).push(shift);
  }

  return (
    <section className={styles.calendar} aria-label={`${month.year}年${month.month}月のシフト`}>
      <div className={styles.nav}>
        <Link href={calendarHref(addMonths(month, -1))} className={styles.navButton} aria-label="前の月">
          ‹
        </Link>
        <h2 className={styles.monthTitle}>
          {month.year}年{month.month}月
        </h2>
        <Link href={calendarHref(addMonths(month, 1))} className={styles.navButton} aria-label="次の月">
          ›
        </Link>
        <Link href={calendarHref(today.slice(0, 7))} className={styles.todayButton}>
          今月
        </Link>
      </div>

      <p className={styles.summary}>
        合計 <strong className={styles.summaryHours}>{formatDuration(summary.minutes)}</strong>
        {`（${summary.count}件）`}
      </p>

      <div className={styles.grid}>
        {WEEKDAYS.map((label, weekday) => (
          <div key={label} className={`${styles.weekday} ${weekdayClass(weekday)}`}>
            {label}
          </div>
        ))}

        {weeks.flat().map((cell) => {
          const dayShifts = shiftsByDate.get(cell.date) ?? [];
          const cellClass = [
            styles.day,
            cell.inMonth ? "" : styles.otherMonth,
            cell.date === today ? styles.today : "",
          ].join(" ");

          return (
            <div key={cell.date} className={cellClass}>
              <span className={`${styles.dayNumber} ${weekdayClass(cell.weekday)}`}>{cell.day}</span>
              <ul className={styles.shiftList}>
                {dayShifts.map((shift) => (
                  <li key={shift.id}>
                    <Link
                      href={`/shifts/${shift.id}/edit?${fromCalendarQuery(month)}`}
                      className={styles.shift}
                      title={`${shift.startTime}-${shift.endTime} ${shift.memo}`.trim()}
                    >
                      <span className={styles.shiftTime}>
                        {shift.startTime}-{shift.endTime}
                      </span>
                      {shift.memo && <span className={styles.shiftMemo}>{shift.memo}</span>}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          );
        })}
      </div>
    </section>
  );
}
