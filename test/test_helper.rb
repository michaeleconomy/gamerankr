ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'stubs'

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  def sign_in(web: false, fb: false)

    assert User.count == 0
    if !fb && !web
      if rand > 0.5
        web = true
      else 
        fb = true
      end
    end
    
    if fb
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

      post "/auth/facebook"
      assert_response :redirect
      follow_redirect!
    else
      password = "foo"
      u = create(:user, password: password)

      post sign_in_path, params: { email: u.email, password: password}
      assert_response 302
    end
    assert User.count == 1
    User.first
  end



  def sign_in_admin
    u = sign_in
    u.create_admin!
    u
  end

  def assert_signed_in
    get "/"
    assert_response 200

    assert_select "a", "Updates"
  end

  def assert_signed_out
    get "/"
    assert_response 200

    assert_select "a", "Create Account"
  end

  def api_execute_graphql(query, variables: nil)
    headers = {}
    if @api_token
      headers["api-token"] = @api_token
    end
    post graphql_path,
      params: {query: query, variables: variables},
      headers: headers
    assert_response 200
    JSON.parse(@response.body)
  end

  def assert_body_contains(s)
    assert @response.body.include?(s)
  end
  

  def sign_in_api
    user = create :user

    @api_token = rand(2**512).to_s(36)
    ios_authorization = user.create_ios_authorization!(
        provider: 'gamerankr-ios',
        uid: user.id,
        token: @api_token)
    user
  end
end
