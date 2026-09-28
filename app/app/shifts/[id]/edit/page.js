import Link from "next/link";
import { notFound } from "next/navigation";
import { calendarHref, formatMonth, parseMonth } from "@/lib/calendar";
import { fetchShift } from "@/lib/shiftsApi";
import ShiftForm from "../../ShiftForm";
import styles from "../../ShiftForm.module.css";

// 戻り先は開いた元の表示にする(カレンダーからは ?from=calendar&month=YYYY-MM が付く)。
// クエリの値をそのまま URL に使わず、一覧かカレンダー(妥当な月)のどちらかに限って組み立てる。
function backTarget({ from, month }) {
  if (from === "calendar") {
    return { href: calendarHref(formatMonth(parseMonth(month))), label: "カレンダーへ戻る" };
  }
  return { href: "/", label: "一覧へ戻る" };
}

export default async function EditShiftPage({ params, searchParams }) {
  const { id } = await params;
  const back = backTarget(await searchParams);

  let shift;
  try {
    shift = await fetchShift(id);
  } catch {
    return (
      <div className={styles.page}>
        <Link href={back.href} className={styles.backLink}>
          ← {back.label}
        </Link>
        <p className={styles.error}>
          シフトを取得できませんでした。バックエンド(Rails API)が起動しているか確認してください。
        </p>
      </div>
    );
  }

  if (!shift) notFound();

  return <ShiftForm initialShift={shift} back={back} />;
}
