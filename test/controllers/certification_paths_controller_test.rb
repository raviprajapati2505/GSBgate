require 'test_helper'

class CertificationPathsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test 'owner can create new certification path' do
    sign_in users(:project_owner)
    project = projects(:one)
    get :new, project_id: project.id
    assert_response :success
    sign_out users(:project_owner)
  end

  test 'owner can create certification path' do
    sign_in users(:project_owner)
    project = projects(:one)
    assert_difference('CertificationPath.count') do
      post :create, project_id: project.id, certification_path: {certificate_id: 4}
    end
    assert_redirected_to project_certification_path_path project_id: project.id, id: assigns(:certification_path).id
    sign_out users(:project_owner)
  end

end