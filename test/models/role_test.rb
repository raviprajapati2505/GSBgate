require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "definition enum is correct" do
    role = Role.new
    role.anonymous!
    assert_equal true, role.anonymous?
  end
end
