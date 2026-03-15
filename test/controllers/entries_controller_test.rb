require "test_helper"

class EntriesControllerTest < ActionDispatch::IntegrationTest
  test "should get update_status" do
    get entries_update_status_url
    assert_response :success
  end
end
