// Rails API(backend/)とのやり取りをまとめたモジュール。
// Rails 側は snake_case、画面側は camelCase で扱うため、ここで相互に変換する。

export const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:3001";

function toShift(json) {
  return {
    id: json.id,
    date: json.date,
    startTime: json.start_time,
    endTime: json.end_time,
    memo: json.memo ?? "",
  };
}

// シフト一覧を日付・開始時刻の昇順で取得する
export async function fetchShifts() {
  const response = await fetch(`${API_BASE_URL}/shifts`);
  if (!response.ok) {
    throw new Error(`シフト一覧の取得に失敗しました(HTTP ${response.status})`);
  }
  const json = await response.json();
  return json.map(toShift);
}

// シフトを1件登録する。バリデーションエラー時は { errors } を返す
export async function createShift({ date, startTime, endTime, memo }) {
  const response = await fetch(`${API_BASE_URL}/shifts`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      shift: { date, start_time: startTime, end_time: endTime, memo },
    }),
  });

  if (response.status === 422) {
    const json = await response.json();
    return { errors: json.errors };
  }
  if (!response.ok) {
    throw new Error(`シフトの登録に失敗しました(HTTP ${response.status})`);
  }
  return { shift: toShift(await response.json()) };
}

// シフトを1件削除する。すでに削除済み(404)の場合も一覧から消えていればよいので成功扱いにする
export async function deleteShift(id) {
  const response = await fetch(`${API_BASE_URL}/shifts/${id}`, { method: "DELETE" });
  if (!response.ok && response.status !== 404) {
    throw new Error(`シフトの削除に失敗しました(HTTP ${response.status})`);
  }
}
