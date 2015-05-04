require 'test_helper'

class ProjectAuthorizationTest < ActiveSupport::TestCase

  fixtures :project_authorizations

  test "project owner authorizations can not be destroyed" do
    authorization = ProjectAuthorization.find_by(user_id: project_authorizations(:one).user_id, project_id: project_authorizations(:one).project_id)
    assert_not_nil authorization
    assert_raise RuntimeError do
      authorization.destroy!
    end
  end

  test "project can be managed by owner" do
    authorization = ProjectAuthorization.find_by(user_id: project_authorizations(:one).user_id, project_id: project_authorizations(:one).project_id)
    ability = Ability.new(authorization.user)
    assert ability.can?(:manage, authorization.project), "owner cannot manage project"
    assert ability.can?(:read, authorization.project), "owner cannot read project"
  end

  test "project can be managed by manager" do
    authorization = ProjectAuthorization.find_by(user_id: project_authorizations(:two).user_id, project_id: project_authorizations(:two).project_id)
    ability = Ability.new(authorization.user)
    assert ability.can?(:manage, authorization.project), "manager cannot manage project"
    assert ability.can?(:read, authorization.project), "manager cannot read project"
  end

  test "project can only be read by readonly team members" do
    authorization = ProjectAuthorization.find_by(user_id: project_authorizations(:four).user_id, project_id: project_authorizations(:four).project_id)
    ability = Ability.new(authorization.user)
    assert ability.can?(:read, authorization.project), "readonly team member cannot read project"
    assert ability.cannot?(:update, authorization.project), "readonly team member can update project"
    assert ability.cannot?(:manage, authorization.project), "readonly team member can manager project"
  end

  test "project can only be read by certifier" do
    user = User.find(users(:bart).id)
    user.certifier!
    project = Project.find(projects(:one).id)
    ability = Ability.new(user)
    assert ability.can?(:read, project), "certifier cannot read project"
    assert ability.cannot?(:update, project), "certifier can update project"
    assert ability.cannot?(:manage, project), "certifier can manager project"
  end

  test "project can not be accessed by non-team members" do
    user = User.find(users(:barry).id)
    project = Project.find(projects(:one).id)
    ability = Ability.new(user)
    assert ability.cannot?(:read, project), "non-team member can read project"
  end
end
