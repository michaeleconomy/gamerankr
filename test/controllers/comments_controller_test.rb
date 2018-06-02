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

  test "create comment" do
    sign_in
    r = create_ranking
    assert Comment.count == 0
    post comments_url(format: 'js'), params: {comment: {resource_id: r.id, resource_type: "Ranking", comment: "foo"}}
    assert_response :success

    assert Comment.count == 1
  end
end