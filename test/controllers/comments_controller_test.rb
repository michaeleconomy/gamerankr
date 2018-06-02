require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest
  test "empty comment list" do
    r = create_ranking
    get ranking_comments_url(r, format: 'json')
    assert_response 200
  end

  test "look at comment list" do
    c = create :comment
    get ranking_comments_url(c.resource, format: 'json')
    assert 200
  end

  test "look at comment list signed in" do
    sign_in
    c = create :comment
    get ranking_comments_url(c.resource, format: 'json')
    assert 200
  end
end