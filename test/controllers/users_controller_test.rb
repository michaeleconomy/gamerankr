require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "user index blank" do
    get users_url
    assert_response 200

  end

  test "user index" do
    r = create_ranking
    f = create :follow
    get users_url
    assert_response 200
    assert_select "a", r.user.real_name
    assert_select "a", f.following.real_name
  end

  test "user all" do
    r = create_ranking
    get users_all_url
    assert_response 200
    assert_select "a", r.user.real_name
  end

  test "user all signed_in" do
    u = sign_in
    create_ranking user: u
    get users_all_url
    assert_response 200
    assert_select "a", u.real_name
  end

  test "user search" do
    u = sign_in
    get users_search_url(query: u.first_name)
    assert_response 200
    assert_select "a", u.real_name
  end

  test "user search no result" do
    sign_in
    get users_search_url(query:"fooooooooo")
    assert_response 200
    assert_select ".userListItem", count: 0
  end

  test "user index signed_in" do
    u = sign_in
    r = create_ranking
    f = create :follow
    get users_url
    assert_response 200
    assert_select "a", r.user.real_name
    assert_select "a", u.real_name, count: 0
    assert_select "a", f.following.real_name
  end

  test "user show" do
    u = create(:user)
    assert u.verified?
    get user_url(u)
    assert_response 200
  end

  test "user edit" do
    u = sign_in
    get edit_user_url(u)
    assert_response 200
  end

  test "user cant edit other" do
    u = sign_in
    other = create :user
    get edit_user_url(other)
    assert_response 302
  end


  test "user update" do
    u = sign_in
    assert u.real_name != "xxx"
    patch user_url(u),
      params: {user: {real_name: "xxx"} }
    assert_response 302
    u.reload
    assert u.real_name == "xxx"
  end

  test "user show doesn't show unverified" do
    u = create(:user, verified_at: nil)
    assert !u.verified?
    get user_url(u)
    assert_response 302
  end

  test "user show signed in" do
    sign_in
    u = create(:user)
    get user_url(u)
    assert_response 200
  end

  test "user show self" do
    signed_in_user = sign_in
    get user_url(signed_in_user)
    assert_response 200
  end

end