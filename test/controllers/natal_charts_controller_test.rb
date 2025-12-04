require "test_helper"

class NatalChartsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get natal_charts_show_url
    assert_response :success
  end

end
