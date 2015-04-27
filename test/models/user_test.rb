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
end