"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { deleteShift } from "@/lib/shiftsApi";
import styles from "./page.module.css";

export default function DeleteShiftButton({ id, label }) {
  const router = useRouter();
  const [deleting, setDeleting] = useState(false);
  const [error, setError] = useState("");

  async function handleClick() {
    if (!window.confirm(`${label} のシフトを削除しますか?`)) return;

    setError("");
    setDeleting(true);
    try {
      await deleteShift(id);
      router.refresh();
    } catch {
      setError("削除に失敗しました");
      setDeleting(false);
    }
  }

  return (
    <>
      <button type="button" className={styles.deleteButton} onClick={handleClick} disabled={deleting}>
        {deleting ? "削除中..." : "削除"}
      </button>
      {error && <span className={styles.deleteError}>{error}</span>}
    </>
  );
}
