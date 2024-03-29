require 'test_helper'

class FollowControllerTest < ActionDispatch::IntegrationTest
  test "follow" do
    current_user = sign_in
    u = create :user

    assert Follow.count == 0

    assert_emails 1 do
      post follow_user_path(u, format: "js")
    end
    assert_response 200

    assert Follow.count == 1
    f = Follow.first
    assert f.follower_id == current_user.id
    assert f.following_id == u.id
  end

  test "follow no email" do
    current_user = sign_in
    u = create :user
    assert u.update(new_follower_email: false)

    assert Follow.count == 0

    assert_emails 0 do
      post follow_user_path(u, format: "js")
    end
    assert_response 200

    assert Follow.count == 1
    f = Follow.first
    assert f.follower_id == current_user.id
    assert f.following_id == u.id
  end

  test "double follow no email" do
    current_user = sign_in
    u = create :user
    assert Follow.count == 0

    assert_emails 1 do
      post follow_user_path(u, format: "js")
    end
    assert_response 200

    assert Follow.count == 1
    f = Follow.first
    assert f.follower_id == current_user.id
    assert f.following_id == u.id


    assert_emails 0 do
      post follow_user_path(u, format: "js")
    end
    assert Follow.count == 1
  end


  test "unfollow" do
    current_user = sign_in

    f = create :follow, follower: current_user
    assert Follow.count == 1

    assert_emails 0 do
      post unfollow_user_path(f.following, format: "js")
    end
    assert_response 200

    assert Follow.count == 0
  end


  test "unfollow not followed user" do
    current_user = sign_in
    u = create :user
    assert Follow.count == 0

    assert_emails 0 do
      post unfollow_user_path(u, format: "js")
    end
    assert_response 404

    assert Follow.count == 0
  end

  test "followings empty" do
    u = create :user

    get following_user_path(u)
    assert_response 200
  end

  test "followers empty" do
    u = create :user

    get followers_user_path(u)
    assert_response 200
  end

  test "followings" do
    f = create :follow
    get following_user_path(f.follower)
    assert_response 200

    assert_select "a", f.following.real_name
  end

  test "followers" do
    f = create :follow
    get followers_user_path(f.following)
    assert_response 200

    assert_select "a", f.follower.real_name
  end

  test "followers self" do
    u = sign_in
    get followers_user_path(u)
    assert_response 200
  end

  test "following self" do
    u = sign_in
    get following_user_path(u)
    assert_response 200
  end

end