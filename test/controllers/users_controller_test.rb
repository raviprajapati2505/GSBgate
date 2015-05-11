require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
    @user = users(:project_owner)
    sign_in users(:system_admin)
  end

  teardown do
    sign_out users(:system_admin)
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
    put :update, id: @user, user: { email: 'project_owner@example.org' }
    assert_redirected_to users_path
  end
end