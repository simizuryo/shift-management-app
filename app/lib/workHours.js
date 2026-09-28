// 勤務時間の集計。時刻は "HH:MM" の文字列で扱う。
// シフトは日をまたがない(終了時刻 > 開始時刻をバックエンドで検証している)ので、終了 − 開始がそのまま勤務時間になる。

function toMinutes(time) {
  const [hours, minutes] = time.split(":").map(Number);
  return hours * 60 + minutes;
}

export function shiftMinutes(shift) {
  return toMinutes(shift.endTime) - toMinutes(shift.startTime);
}

// "YYYY-MM" の月のシフトの件数と合計勤務時間(分)
export function summarizeMonth(shifts, month) {
  const monthShifts = shifts.filter((shift) => shift.date.startsWith(`${month}-`));
  return {
    count: monthShifts.length,
    minutes: monthShifts.reduce((total, shift) => total + shiftMinutes(shift), 0),
  };
}

// 分を "12時間30分" / "8時間" の形にする
export function formatDuration(totalMinutes) {
  const hours = Math.floor(totalMinutes / 60);
  const minutes = totalMinutes % 60;
  return minutes === 0 ? `${hours}時間` : `${hours}時間${minutes}分`;
}
