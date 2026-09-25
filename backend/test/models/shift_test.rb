require "test_helper"

class ShiftTest < ActiveSupport::TestCase
  def build_shift(**attrs)
    Shift.new({ date: "2026-09-25", start_time: "09:00", end_time: "17:00" }.merge(attrs))
  end

  test "valid with required attributes and no memo" do
    assert build_shift.valid?
  end

  test "requires date, start_time and end_time" do
    shift = Shift.new
    assert_not shift.valid?
    assert_includes shift.errors.attribute_names, :date
    assert_includes shift.errors.attribute_names, :start_time
    assert_includes shift.errors.attribute_names, :end_time
  end

  test "end_time must be after start_time" do
    assert_not build_shift(end_time: "09:00").valid?
    assert_not build_shift(end_time: "08:00").valid?
  end

  test "ordered sorts by date then start_time" do
    Shift.create!(date: "2026-09-25", start_time: "07:00", end_time: "08:00")
    times = Shift.ordered.map { |s| [ s.date.iso8601, s.start_time.strftime("%H:%M") ] }
    assert_equal [ [ "2026-09-25", "07:00" ], [ "2026-09-25", "09:00" ], [ "2026-09-26", "13:00" ] ], times
  end
end
