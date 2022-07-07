require 'test_helper'

class UserControllerTest < ActionDispatch::IntegrationTest
  test "user index" do
    get users_url
    assert_response 200
  end

  test "user show" do
    u = create(:user)
    assert u.verified?
    get user_url(u)
    assert_response 200
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