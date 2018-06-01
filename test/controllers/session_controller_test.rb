require 'test_helper'

class SessionControllerTest < ActionDispatch::IntegrationTest
  test "sign in - create" do
    sign_in

    assert_response :redirect
    follow_redirect!
    assert_response 200
  end

  test "sign in - create - no email" do
    assert User.count == 0
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

    get "/auth/facebook"
    assert_response :redirect
    follow_redirect!

    assert_response :redirect
    assert User.count == 1
  end
end
