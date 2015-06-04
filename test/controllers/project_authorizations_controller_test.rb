require 'test_helper'

class ProjectAuthorizationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do

  end

  teardown do

  end

  test "owner should get index" do
    sign_in users(:project_owner)
    get :index, project_id: projects(:one).id
    assert_response :success
    assert_not_nil assigns(:project_authorizations)
    sign_out users(:project_owner)
  end

  test "owner should get new" do
    sign_in users(:project_owner)
    get :new, project_id: projects(:one).id
    assert_response :success
    sign_out users(:project_owner)
  end

  test "owner should create project authorization" do
    sign_in users(:project_owner)
    assert_difference('ProjectAuthorization.count') do
      post :create, authorization: {user_id: users(:project_team_member_2).id, permission: 'read_only', category_id: categories(:one).id}, project_id: projects(:one).id
    end
    assert_redirected_to project_project_authorizations_path(project_id: projects(:one).id)
    sign_out users(:project_owner)
  end

  test "owner should get edit" do
    sign_in users(:project_owner)
    get :edit, project_id: projects(:one).id, id: project_authorizations(:one).id
    assert_response :success
    sign_out users(:project_owner)
  end

  test "owner should update project authorization" do
    sign_in users(:project_owner)
    patch :update, authorization: {user_id: users(:project_team_member).id, permission: 'read_write', category_id: categories(:two).id}, project_id: projects(:one).id, id: project_authorizations(:one).id
    assert_redirected_to project_project_authorizations_path(project_id: projects(:one).id)
    sign_out users(:project_owner)
  end

  test "owner should destroy project authorization" do
    sign_in users(:project_owner)
    assert_difference('ProjectAuthorization.count', -1) do
      delete :destroy, project_id: projects(:one).id, id: project_authorizations(:one).id
    end
    assert_redirected_to project_project_authorizations_path(project_id: projects(:one).id)
    sign_out users(:project_owner)
  end

end
