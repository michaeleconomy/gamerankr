require "test_helper"

class UpdatesControllerTest < ActionDispatch::IntegrationTest
  test "signed_out updates" do
    get updates_url
    assert_response 302
  end

  test "no followings" do
    sign_in
    get updates_url
    assert_response 200

    assert_select "div", "You are not following anyone yet.  Follow some other users to get updates!"
  end

  test "followings but no updates" do
    u1 = sign_in

    f = create(:follow, follower: u1)
    get updates_url
    assert_response 200

    assert_select "div", "The people you are following do not yet have any updates.  Follow more people for updates."
  end


  test "followings with updates" do
    u1 = sign_in

    f = create(:follow, follower: u1)
    create_ranking(user: f.following)
    get updates_url
    assert_response 200

    assert_select "a", f.following.real_name
  end
end
