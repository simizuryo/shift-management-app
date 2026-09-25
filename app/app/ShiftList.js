import Link from "next/link";
import DeleteShiftButton from "./DeleteShiftButton";
import styles from "./page.module.css";

function formatDate(isoDate) {
  const [year, month, day] = isoDate.split("-");
  return `${year}/${month}/${day}`;
}

// シフトの一覧表示(テーブル)。各行から編集・削除ができる
export default function ShiftList({ shifts }) {
  if (shifts.length === 0) {
    return (
      <div className={styles.emptyState}>
        <p>まだシフトが登録されていません</p>
        <Link href="/shifts/new" className={styles.newButton}>
          + 新規登録
        </Link>
      </div>
    );
  }

  return (
    <table className={styles.table}>
      <thead>
        <tr>
          <th>日付</th>
          <th>時間</th>
          <th>メモ</th>
          <th className={styles.actionCell}>操作</th>
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
            <td className={styles.actionCell}>
              <Link href={`/shifts/${shift.id}/edit`} className={styles.editButton}>
                編集
              </Link>
              <DeleteShiftButton
                id={shift.id}
                label={`${formatDate(shift.date)} ${shift.startTime}-${shift.endTime}`}
              />
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}
