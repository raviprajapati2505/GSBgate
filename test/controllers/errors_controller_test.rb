require 'test_helper'

class ErrorsControllerTest < ActionController::TestCase
  test "should get forbidden" do
    get :forbidden
    assert_response :forbidden
    assert_select 'h1', '403'
  end

  test "should get not_found" do
    get :not_found
    assert_response :not_found
    assert_select 'h1', '404'
  end

  test "should get unprocessable_entity" do
    get :unprocessable_entity
    assert_response :unprocessable_entity
    assert_select 'h1', '422'
  end

  test "should get internal_server_error" do
    get :internal_server_error
    assert_response :internal_server_error
    assert_select 'h1', '500'
  end
end
