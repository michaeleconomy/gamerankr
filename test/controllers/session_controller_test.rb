require 'test_helper'

class SessionControllerTest < ActionDispatch::IntegrationTest
  test "sign in - create" do
    assert User.count == 0
    assert Authorization.count == 0
    assert_emails 1 do
      sign_in fb: true
      assert_response :redirect
      follow_redirect!
    end

    assert User.count == 1
    assert Authorization.count == 1
    assert_response 200
  end

  test "sign in - create - no email" do
    assert User.count == 0
    assert Authorization.count == 0
    OmniAuth.config.mock_auth[:facebook] = {
      'provider' => 'facebook',
      'uid' => '123545',
      'info' => {
        'name' => 'mockuser'
      },
      'credentials' => {
        'token' => 'mock_token',
        'secret' => 'mock_secret'
      }
    }

    assert_emails 0 do
      post "/auth/facebook"
      assert_response :redirect
      follow_redirect!
    end

    assert_response :redirect
    assert User.count == 1
    u = User.first
    assert u.email == nil
    assert Authorization.count == 1
  end


  test "sign in with facebook - existing email" do
    u = create :user
    assert u.email
    assert Authorization.count == 0
    assert User.count == 1
    OmniAuth.config.mock_auth[:facebook] = {
      'provider' => 'facebook',
      'uid' => '123545',
      'info' => {
        'name' => 'mockuser',
        'email' => u.email
      },
      'credentials' => {
        'token' => 'mock_token',
        'secret' => 'mock_secret'
      }
    }

    assert_emails 0 do
      post "/auth/facebook"
      assert_response :redirect
      follow_redirect!
    end
    assert_signed_in
    assert User.count == 1
    assert Authorization.count == 1

    assert session[:user_id] == u.id
  end


  test "sign in facebook existing email - already fb connected" do
    u = create :user
    u.authorizations.create!(provider: 'facebook', uid: 'sdfgsdf')
    assert Authorization.count == 1
    assert User.count == 1
    OmniAuth.config.mock_auth[:facebook] = {
      'provider' => 'facebook',
      'uid' => '123545',
      'info' => {
        'name' => 'mockuser',
        'email' => u.email
      },
      'credentials' => {
        'token' => 'mock_token',
        'secret' => 'mock_secret'
      }
    }

    assert_emails 0 do
      post "/auth/facebook"
      assert_response :redirect
      follow_redirect!
    end
    assert_signed_out
    assert User.count == 1
    assert Authorization.count == 1
  end

  test "sign in facebook existing email - connected to different account" do
    u = create :user
    u.authorizations.create!(provider: 'facebook', uid: 'sdfgsdf')
    other = create :user
    other.authorizations.create!(provider: 'facebook', uid: 'xxx')
    assert Authorization.count == 2
    assert User.count == 2
    OmniAuth.config.mock_auth[:facebook] = {
      'provider' => 'facebook',
      'uid' => 'xxx',
      'info' => {
        'name' => 'mockuser',
        'email' => u.email
      },
      'credentials' => {
        'token' => 'mock_token',
        'secret' => 'mock_secret'
      }
    }

    post "/auth/facebook"
    assert_response :redirect
    follow_redirect!
    assert_signed_out
    assert Authorization.count == 2
    assert User.count == 2
  end
end
