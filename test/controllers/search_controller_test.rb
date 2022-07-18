require 'test_helper'

class SearchControllerTest < ActionDispatch::IntegrationTest
  test "search" do
    get search_url
    assert_response 200
  end
 
  test "search for game" do
    port = create :port
    game = port.game
    get search_url(:query => game.title)
    assert_response 200
    assert_select "a", game.title
  end
end
