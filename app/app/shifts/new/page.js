import { backTarget } from "../backTarget";
import ShiftForm from "../ShiftForm";

export default async function NewShiftPage({ searchParams }) {
  return <ShiftForm back={backTarget(await searchParams)} />;
}
