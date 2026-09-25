class ShiftsController < ApplicationController
  # GET /shifts
  def index
    render json: Shift.ordered.map { |shift| serialize(shift) }
  end

  # POST /shifts
  def create
    shift = Shift.new(shift_params)

    if shift.save
      render json: serialize(shift), status: :created
    else
      render json: { errors: shift.errors.full_messages }, status: :unprocessable_content
    end
  end

  # DELETE /shifts/:id
  def destroy
    shift = Shift.find_by(id: params[:id])
    return head :not_found unless shift

    shift.destroy!
    head :no_content
  end

  private

  def shift_params
    params.expect(shift: [ :date, :start_time, :end_time, :memo ])
  end

  # time カラムはダミー日付(2000-01-01)付きで返るため、"HH:MM" 形式に整形する
  def serialize(shift)
    {
      id: shift.id,
      date: shift.date.iso8601,
      start_time: shift.start_time.strftime("%H:%M"),
      end_time: shift.end_time.strftime("%H:%M"),
      memo: shift.memo
    }
  end
end
