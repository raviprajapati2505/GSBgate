require 'test_helper'

class SchemeMixesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  fixtures :certification_paths, :scheme_mixes, :scheme_mix_criteria, :scheme_mix_criteria_requirement_data, :requirement_data, :calculator_data, :field_data

  test 'owner can show scheme mix' do
    sign_in users(:project_owner)
    project = projects(:one)
    certification_path = certification_paths(:one)
    scheme = scheme_mixes(:one)
    get :show, project_id: project.id, certification_path_id: certification_path.id, id: scheme.id
    assert_response :success
    assert_select '.accordion-body tbody tr', 2, 'wrong number of criteria'
    sign_out users(:project_owner)
  end

  test 'member can show scheme mix' do
    sign_in users(:project_team_member)
    project = projects(:one)
    certification_path = certification_paths(:one)
    scheme = scheme_mixes(:one)
    get :show, project_id: project.id, certification_path_id: certification_path.id, id: scheme.id
    assert_response :success
    assert_select '.accordion-body tbody tr', 1, 'wrong number of criteria'
    sign_out users(:project_team_member)
  end

  test 'project manager can show scheme mix' do
    sign_in users(:project_manager)
    project = projects(:one)
    certification_path = certification_paths(:one)
    scheme = scheme_mixes(:one)
    get :show, project_id: project.id, certification_path_id: certification_path.id, id: scheme.id
    assert_response :success
    assert_select '.accordion-body tbody tr', 2, 'wrong number of criteria'
    sign_out users(:project_manager)
  end

  test 'client can show scheme mix' do
    sign_in users(:enterprise_licence)
    project = projects(:one)
    certification_path = certification_paths(:one)
    scheme = scheme_mixes(:one)
    get :show, project_id: project.id, certification_path_id: certification_path.id, id: scheme.id
    assert_select '.accordion-body tbody tr', 2, 'wrong number of criteria'
    sign_out users(:enterprise_licence)
  end

  test 'project admin can show scheme mix' do
    sign_in users(:project_admin)
    project = projects(:one)
    certification_path = certification_paths(:one)
    scheme = scheme_mixes(:one)
    get :show, project_id: project.id, certification_path_id: certification_path.id, id: scheme.id
    assert_select '.accordion-body tbody tr', 2, 'wrong number of criteria'
    sign_out users(:project_admin)
  end
end