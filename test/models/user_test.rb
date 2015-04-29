require 'test_helper'

class UserTest < ActiveSupport::TestCase

  fixtures :users

  test "user role can be assigned" do
    user = users(:bart)
    user.admin!
    assert_equal true, user.admin?
    assert_equal false, user.anonymous?
    user.registered!
    assert_equal false, user.certifier?
    assert_equal true, user.registered?
  end

  test "user is authorized for writing a category of 1 project" do
    user = User.find_by(id: users(:bart).id)
    assert_not_nil user.projects
    assert_equal 1, user.projects.size
    assert_equal true, user.project_authorizations[0].write_access?
  end
end