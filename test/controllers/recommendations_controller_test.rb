require 'test_helper'

class RecommendationsControllerTest < ActionDispatch::IntegrationTest
  test "recs signed out" do
    get recommendations_url
    assert_response :redirect
  end

  test "recs empty" do
    sign_in_admin
    get recommendations_url
    assert_response 200
  end

  test "shows recommendation" do
    u = sign_in_admin
    r = create :recommendation, user: u
    get recommendations_url
    assert_response 200
    assert_select "a", r.game.title
  end
end
