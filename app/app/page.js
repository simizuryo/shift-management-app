import Link from "next/link";
import styles from "./page.module.css";

// TODO: Rails APIから取得したデータに置き換える(現在はモックデータ)
const shifts = [
  { id: 1, date: "2026-09-25", startTime: "09:00", endTime: "17:00", memo: "レジ対応" },
  { id: 2, date: "2026-09-26", startTime: "13:00", endTime: "18:00", memo: "" },
  { id: 3, date: "2026-09-28", startTime: "09:00", endTime: "17:00", memo: "棚卸し" },
];

function formatDate(isoDate) {
  const [year, month, day] = isoDate.split("-");
  return `${year}/${month}/${day}`;
}

export default function ShiftListPage() {
  return (
    <div className={styles.page}>
      <header className={styles.header}>
        <h1 className={styles.title}>シフト管理アプリ</h1>
      </header>

      <main className={styles.main}>
        <div className={styles.toolbar}>
          <Link href="/shifts/new" className={styles.newButton}>
            + 新規登録
          </Link>
        </div>

        {shifts.length === 0 ? (
          <div className={styles.emptyState}>
            <p>まだシフトが登録されていません</p>
            <Link href="/shifts/new" className={styles.newButton}>
              + 新規登録
            </Link>
          </div>
        ) : (
          <table className={styles.table}>
            <thead>
              <tr>
                <th>日付</th>
                <th>時間</th>
                <th>メモ</th>
              </tr>
            </thead>
            <tbody>
              {shifts.map((shift) => (
                <tr key={shift.id}>
                  <td>{formatDate(shift.date)}</td>
                  <td>
                    {shift.startTime}-{shift.endTime}
                  </td>
                  <td className={styles.memoCell}>{shift.memo}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </main>
    </div>
  );
}
