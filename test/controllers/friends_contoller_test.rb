require 'test_helper'

class FriendssControllerTest < ActionDispatch::IntegrationTest
  test "signed out" do
    get friends_url
    assert_response :redirect
  end

  test "Empty list" do
    sign_in
    get friends_url
    assert_response 200
  end

  test "has friends" do
    u = sign_in
    get root_url #to flush the facebook thingy
    u2 = create(:user, :real_name => "frank")
    Friend.make(u.id, u2.id)

    get friends_url
    assert_response 200
    assert_select "a", u2.real_name
  end



  test "has friend update" do
    u = sign_in
    get root_url #to flush the facebook thingy
    r = create_ranking
    u2 = r.user
    Friend.make(u.id, u2.id)

    get friends_url
    assert_select "a", r.game.title
  end

end