require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  test "user factory" do
    user = create :user
    assert user != nil
    assert user.id > 0
    assert user.verified?
  end
  
  test "user destroy" do
    user = create :user
    assert user
    assert user.destroy
  end
end
