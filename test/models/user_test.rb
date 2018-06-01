require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "user factory" do
    user = create :user
    assert user != nil
    assert user.id > 0
  end
end
