require 'test_helper'

class FriendUpdatesMailerTest < ActionDispatch::IntegrationTest
  test "no updates" do
    create :user

    assert_emails 0 do
      FriendUpdatesMailer.send_all
    end
  end


  test "send update" do
    u = create :user

    r = create_ranking created_at: 3.days.ago, updated_at: 3.days.ago

    u.followings.create! following_id: r.user_id

    all_updates = FriendUpdatesMailer.get_all_updates(Date.today)

    assert all_updates.size == 1

    assert_emails 1 do
      FriendUpdatesMailer.send_all
    end
  end
end