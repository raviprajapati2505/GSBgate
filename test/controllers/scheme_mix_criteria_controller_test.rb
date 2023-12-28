require 'test_helper'

class SchemeMixCriteriaControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  fixtures :certification_paths, :scheme_mixes, :scheme_mix_criteria, :scheme_mix_criteria_requirement_data, :requirement_data, :calculator_data, :field_data

  test 'owner can edit scheme mix criteria' do
    sign_in users(:project_owner)
    project = projects(:one)
    certification_path = certification_paths(:one)
    scheme = scheme_mixes(:one)
    scheme_mix_criteria = scheme_mix_criteria(:one)
    get :edit, project_id: project.id, certification_path_id: certification_path.id, scheme_mix_id: scheme.id, id: scheme_mix_criteria.id
    assert_response :success
    assert_select '#accordion > div', 2, 'wrong number of requirements'
    assert_select '#accordion select[name="[user_id]"]', 2, 'wrong number of "assign to member" select boxes'
    sign_out users(:project_owner)
  end

  test 'member can edit scheme mix criteria' do
    sign_in users(:project_team_member)
    project = projects(:one)
    certification_path = certification_paths(:one)
    scheme = scheme_mixes(:one)
    scheme_mix_criteria = scheme_mix_criteria(:one)
    get :edit, project_id: project.id, certification_path_id: certification_path.id, scheme_mix_id: scheme.id, id: scheme_mix_criteria.id
    assert_response :success
    assert_select '#accordion > div', 2, 'wrong number of requirements'
    assert_select '#accordion select[name="[user_id]"]', 0, 'wrong number of "assign to member" select boxes'
    sign_out users(:project_team_member)
  end

  test 'project manager can edit scheme mix criteria' do
    sign_in users(:cgp_project_manager)
    project = projects(:one)
    certification_path = certification_paths(:one)
    scheme = scheme_mixes(:one)
    scheme_mix_criteria = scheme_mix_criteria(:one)
    get :edit, project_id: project.id, certification_path_id: certification_path.id, scheme_mix_id: scheme.id, id: scheme_mix_criteria.id
    assert_response :success
    assert_select '#accordion > div', 2, 'wrong number of requirements'
    assert_select '#accordion select[name="[user_id]"]', 2, 'wrong number of "assign to member" select boxes'
    sign_out users(:cgp_project_manager)
  end

  test 'client can edit scheme mix criteria' do
    sign_in users(:enterprise_licence)
    project = projects(:one)
    certification_path = certification_paths(:one)
    scheme = scheme_mixes(:one)
    scheme_mix_criteria = scheme_mix_criteria(:one)
    get :edit, project_id: project.id, certification_path_id: certification_path.id, scheme_mix_id: scheme.id, id: scheme_mix_criteria.id
    assert_response :success
    assert_select '#accordion > div', 2, 'wrong number of requirements'
    assert_select '#accordion select[name="[user_id]"]', 1, 'wrong number of "assign to member" select boxes'
    sign_out users(:enterprise_licence)
  end

  test 'project admin can edit scheme mix criteria' do
    sign_in users(:project_admin)
    project = projects(:one)
    certification_path = certification_paths(:one)
    scheme = scheme_mixes(:one)
    scheme_mix_criteria = scheme_mix_criteria(:one)
    get :edit, project_id: project.id, certification_path_id: certification_path.id, scheme_mix_id: scheme.id, id: scheme_mix_criteria.id
    assert_response :success
    assert_select '#accordion > div', 2, 'wrong number of requirements'
    assert_select '#accordion select[name="[user_id]"]', 2, 'wrong number of "assign to member" select boxes'
    sign_out users(:project_admin)
  end

end