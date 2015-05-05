require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
    @user = users(:bart)
    sign_in users(:admin)
  end

  teardown do
    sign_out users(:admin)
  end

  test "should show users" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    put :update, id: @user, user: { email: 'bart@example.org' }
    assert_redirected_to users_path
  end
end