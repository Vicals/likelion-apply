require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get home_index_url
    assert_response :success
  end

  test "should get view" do
    get home_view_url
    assert_response :success
  end

  test "should get list" do
    get home_list_url
    assert_response :success
  end

end
