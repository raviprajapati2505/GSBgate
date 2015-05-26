require 'test_helper'

class UserTest < ActiveSupport::TestCase

  fixtures :users

  test "user role can be assigned" do
    user = users(:system_admin)
    user.project_team_member!
    assert_equal false, user.project_owner?
    assert_equal true, user.project_team_member?
  end

end