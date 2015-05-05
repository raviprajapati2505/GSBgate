require 'test_helper'

class ProjectTest < ActiveSupport::TestCase

  fixtures :projects

  test "project can be managed by owner" do
    project = Project.find_by(id: projects(:one))
    ability = Ability.new(project.owner)
    assert ability.can?(:manage, project), "owner cannot manage project"
    assert ability.can?(:read, project), "owner cannot read project"
  end
end
