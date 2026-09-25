require "test_helper"

class ShiftsControllerTest < ActionDispatch::IntegrationTest
  test "index returns shifts ordered by date and start_time" do
    get shifts_url
    assert_response :success

    body = response.parsed_body
    assert_equal [ "2026-09-25", "2026-09-26" ], body.map { |s| s["date"] }
    assert_equal({ "date" => "2026-09-25", "start_time" => "09:00", "end_time" => "17:00", "memo" => "レジ対応" },
                 body.first.except("id"))
  end

  test "create registers a shift" do
    assert_difference("Shift.count", 1) do
      post shifts_url, params: { shift: { date: "2026-09-28", start_time: "09:00", end_time: "17:00", memo: "棚卸し" } }, as: :json
    end
    assert_response :created
    assert_equal "棚卸し", response.parsed_body["memo"]
  end

  test "create returns 422 with errors when invalid" do
    assert_no_difference("Shift.count") do
      post shifts_url, params: { shift: { date: "2026-09-28", start_time: "17:00", end_time: "09:00" } }, as: :json
    end
    assert_response :unprocessable_content
    assert_not_empty response.parsed_body["errors"]
  end

  test "allows CORS from the Next.js dev server" do
    get shifts_url, headers: { "Origin" => "http://localhost:3000" }
    assert_equal "http://localhost:3000", response.headers["Access-Control-Allow-Origin"]
  end

  test "destroy deletes the shift" do
    assert_difference("Shift.count", -1) do
      delete shift_url(shifts(:earlier))
    end
    assert_response :no_content
  end

  test "destroy returns 404 for a missing shift" do
    assert_no_difference("Shift.count") do
      delete shift_url(id: 0)
    end
    assert_response :not_found
  end

  test "allows CORS preflight for DELETE" do
    process :options, shift_url(shifts(:earlier)),
            headers: { "Origin" => "http://localhost:3000", "Access-Control-Request-Method" => "DELETE" }
    assert_equal "http://localhost:3000", response.headers["Access-Control-Allow-Origin"]
    assert_includes response.headers["Access-Control-Allow-Methods"], "DELETE"
  end

  test "show returns the shift" do
    get shift_url(shifts(:earlier))
    assert_response :success
    assert_equal({ "date" => "2026-09-25", "start_time" => "09:00", "end_time" => "17:00", "memo" => "レジ対応" },
                 response.parsed_body.except("id"))
  end

  test "show returns 404 for a missing shift" do
    get shift_url(id: 0)
    assert_response :not_found
  end

  test "update changes the shift" do
    patch shift_url(shifts(:earlier)),
          params: { shift: { date: "2026-09-27", start_time: "10:00", end_time: "15:00", memo: "品出し" } }, as: :json
    assert_response :success
    assert_equal({ "date" => "2026-09-27", "start_time" => "10:00", "end_time" => "15:00", "memo" => "品出し" },
                 response.parsed_body.except("id"))
    assert_equal "品出し", shifts(:earlier).reload.memo
  end

  test "update returns 422 with errors when invalid" do
    patch shift_url(shifts(:earlier)), params: { shift: { start_time: "18:00" } }, as: :json
    assert_response :unprocessable_content
    assert_not_empty response.parsed_body["errors"]
    assert_equal "09:00", shifts(:earlier).reload.start_time.strftime("%H:%M")
  end

  test "update returns 404 for a missing shift" do
    patch shift_url(id: 0), params: { shift: { memo: "x" } }, as: :json
    assert_response :not_found
  end

  test "allows CORS preflight for PATCH" do
    process :options, shift_url(shifts(:earlier)),
            headers: { "Origin" => "http://localhost:3000", "Access-Control-Request-Method" => "PATCH" }
    assert_includes response.headers["Access-Control-Allow-Methods"], "PATCH"
  end
end
