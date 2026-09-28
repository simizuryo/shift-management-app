import Link from "next/link";
import { notFound } from "next/navigation";
import { fetchShift } from "@/lib/shiftsApi";
import { backTarget } from "../../backTarget";
import ShiftForm from "../../ShiftForm";
import styles from "../../ShiftForm.module.css";

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
