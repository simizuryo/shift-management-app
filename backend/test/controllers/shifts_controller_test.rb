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
end
