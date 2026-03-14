require "test_helper"

class SignageControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get signage_show_url
    assert_response :success
  end
end
