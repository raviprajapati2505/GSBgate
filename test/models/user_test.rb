require 'test_helper'

class UserTest < ActiveSupport::TestCase

  fixtures :users

  test "user role can be assigned" do
    user = users(:bart)
    user.admin!
    assert_equal true, user.admin?
  end
end