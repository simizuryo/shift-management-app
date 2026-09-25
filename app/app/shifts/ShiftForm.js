"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createShift, updateShift } from "@/lib/shiftsApi";
import styles from "./ShiftForm.module.css";

const EMPTY_SHIFT = { date: "", startTime: "", endTime: "", memo: "" };

// シフトの登録画面(画面B)・編集画面(画面C)で共通のフォーム。
// initialShift を渡すと編集モードになり、その値を入力済みの状態で表示する。
export default function ShiftForm({ initialShift }) {
  const router = useRouter();
  const isEdit = Boolean(initialShift);
  const [form, setForm] = useState(() =>
    isEdit
      ? {
          date: initialShift.date,
          startTime: initialShift.startTime,
          endTime: initialShift.endTime,
          memo: initialShift.memo,
        }
      : EMPTY_SHIFT,
  );
  const [error, setError] = useState("");
  const [submitting, setSubmitting] = useState(false);

  function handleChange(event) {
    const { name, value } = event.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  }

  async function handleSubmit(event) {
    event.preventDefault();

    if (!form.date || !form.startTime || !form.endTime) {
      setError("日付・開始時刻・終了時刻は必須です");
      return;
    }
    if (form.endTime <= form.startTime) {
      setError("終了時刻は開始時刻より後にしてください");
      return;
    }

    setError("");
    setSubmitting(true);
    try {
      const result = isEdit ? await updateShift(initialShift.id, form) : await createShift(form);
      if (result.errors) {
        setError(result.errors.join(" / "));
        setSubmitting(false);
        return;
      }
      router.push("/");
      router.refresh();
    } catch {
      setError(
        `${isEdit ? "更新" : "登録"}に失敗しました。バックエンド(Rails API)が起動しているか確認してください。`,
      );
      setSubmitting(false);
    }
  }

  return (
    <div className={styles.page}>
      <Link href="/" className={styles.backLink}>
        ← 一覧へ戻る
      </Link>

      <h1 className={styles.title}>{isEdit ? "シフトを編集" : "シフトを登録"}</h1>

      <form className={styles.form} onSubmit={handleSubmit}>
        <div className={`${styles.field} ${styles.fieldDate}`}>
          <label htmlFor="date">日付</label>
          <input id="date" name="date" type="date" value={form.date} onChange={handleChange} />
        </div>

        <div className={`${styles.field} ${styles.fieldStart}`}>
          <label htmlFor="startTime">開始時刻</label>
          <input
            id="startTime"
            name="startTime"
            type="time"
            value={form.startTime}
            onChange={handleChange}
          />
        </div>

        <div className={`${styles.field} ${styles.fieldEnd}`}>
          <label htmlFor="endTime">終了時刻</label>
          <input
            id="endTime"
            name="endTime"
            type="time"
            value={form.endTime}
            onChange={handleChange}
          />
        </div>

        <div className={`${styles.field} ${styles.fieldMemo}`}>
          <label htmlFor="memo">メモ(任意)</label>
          <input id="memo" name="memo" type="text" value={form.memo} onChange={handleChange} />
        </div>

        {error && <p className={styles.error}>{error}</p>}

        <div className={styles.actions}>
          <Link href="/" className={styles.cancelButton}>
            キャンセル
          </Link>
          <button type="submit" className={styles.submitButton} disabled={submitting}>
            {submitting ? (isEdit ? "更新中..." : "登録中...") : isEdit ? "更新する" : "登録する"}
          </button>
        </div>
      </form>
    </div>
  );
}
