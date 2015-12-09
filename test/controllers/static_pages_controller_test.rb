require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
  end

  test "should get know_more" do
    get :know_more
    assert_response :success
  end

  test "should get things_we_worked_on" do
    get :things_we_worked_on
    assert_response :success
  end

  test "should get more_about_us" do
    get :more_about_us
    assert_response :success
  end

end
