ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'stubs'

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  def sign_in
    assert User.count == 0
    OmniAuth.config.mock_auth[:facebook] = {
      'provider' => 'facebook',
      'uid' => '123545',
      'info' => {
        'name' => 'mockuser',
        'email' => 'fooboo@sss.gmails.org'
      },
      'credentials' => {
        'token' => 'mock_token',
        'secret' => 'mock_secret'
      }
    }

    get "/auth/facebook"
    assert_response :redirect
    follow_redirect!
    assert User.count == 1
    User.first
  end

  def sign_in_admin
    u = sign_in
    u.create_admin!
    u
  end
end
