require "test_helper"

class FollowTest < ActiveSupport::TestCase
  test "create" do
    follow = create :follow
    assert follow != nil
    assert follow.follower
    assert follow.following

    assert follow.follower.followings.count == 1


    assert follow.following.followers.count == 1
  end

  test "delete" do
    follow = create :follow
    follower = follow.follower
    following = follow.following
    assert follower.followings.count == 1


    assert following.followers.count == 1
    follow.destroy

    follower.reload

    assert follower.followings.count == 0

    following.reload
    assert following.followers.count == 0
  end
end
