require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test 'owner should get projects index' do
    sign_in users(:project_owner)
    get :index
    assert_response :success
    assert_not_nil assigns(:projects)
    sign_out users(:project_owner)
  end

  test 'owner can show project' do
    sign_in users(:project_owner)
    project = projects(:one)
    get :show, id: project.id
    assert_response :success
    assert_not_nil assigns(:project)
    assert_select 'h5:last-of-type', 'Project team'
    sign_out users(:project_owner)
  end

  test 'member can show project' do
    sign_in users(:project_team_member)
    project = projects(:one)
    get :show, id: project.id
    assert_response :success
    assert_not_nil assigns(:project)
    assert_select 'h5:last-of-type', 'Project Tasks'
    sign_out users(:project_team_member)
  end

  test 'client can show project' do
    sign_in users(:enterprise_licence)
    project = projects(:one)
    get :show, id: project.id
    assert_response :success
    assert_not_nil assigns(:project)
    assert_select 'h5:last-of-type', 'Project team'
    sign_out users(:enterprise_licence)
  end

end
