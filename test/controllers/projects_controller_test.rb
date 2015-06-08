require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test 'owner_should_get_index' do
    sign_in users(:project_owner)
    get :index
    assert_response :success
    assert_not_nil assigns(:projects)
    sign_out users(:project_owner)
  end
end