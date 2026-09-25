class ShiftsController < ApplicationController
  before_action :set_shift, only: %i[show update destroy]

  # GET /shifts
  def index
    render json: Shift.ordered.map { |shift| serialize(shift) }
  end

  # GET /shifts/:id
  def show
    render json: serialize(@shift)
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

  # PATCH /shifts/:id
  def update
    if @shift.update(shift_params)
      render json: serialize(@shift)
    else
      render json: { errors: @shift.errors.full_messages }, status: :unprocessable_content
    end
  end

  # DELETE /shifts/:id
  def destroy
    @shift.destroy!
    head :no_content
  end

  private

  def set_shift
    @shift = Shift.find_by(id: params[:id])
    head :not_found unless @shift
  end

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
