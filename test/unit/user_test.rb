require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "unique nickname" do
    assert_equal false, User.unique_nickname(nil).blank?
    assert_equal false, User.unique_nickname("").blank?
  end
end
