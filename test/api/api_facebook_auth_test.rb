require 'test_helper'

class ApiFacebookAuthTest < ActionDispatch::IntegrationTest

  test "sign in mobile - create" do
    assert Authorization.count == 0
    assert User.count == 0
    assert_emails 1 do
      get login_url(fb_auth_token: "foo")
      assert_response 200
    end
    assert Authorization.count == 2
    assert User.count == 1

    assert_signed_in
  end

  test "sign in mobile - facebook - existing" do
    u = create :user
    u.authorizations.create! provider: 'facebook', uid: 'xxx'

    FbGraph2::User.stub(:email, u.email)
    FbGraph2::User.stub(:id, 'xxx')

    assert Authorization.count == 1
    assert User.count == 1

    assert_emails 0 do
      get login_url(fb_auth_token: "foo")
      assert_response 200
    end
    assert Authorization.count == 2
    assert User.count == 1

    assert_signed_in
  end

  test "sign in mobile - facebook - duplicate" do
    u = create :user
    u.authorizations.create! provider: 'facebook', uid: 'xxx'

    FbGraph2::User.stub(:email, u.email)
    FbGraph2::User.stub(:id, 'yyy')

    assert Authorization.count == 1
    assert User.count == 1

    assert_emails 0 do
      get login_url(fb_auth_token: "foo")
      assert_response 400
    end
    assert Authorization.count == 1
    assert User.count == 1

    assert_signed_out
  end
end