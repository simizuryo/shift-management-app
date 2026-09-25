class Shift < ApplicationRecord
  validates :date, :start_time, :end_time, presence: true
  validate :end_time_after_start_time

  scope :ordered, -> { order(:date, :start_time) }

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?

    errors.add(:end_time, "must be after start time") if end_time <= start_time
  end
end
