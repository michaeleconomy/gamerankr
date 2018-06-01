require 'test_helper'

class GamesControllerTest < ActionDispatch::IntegrationTest
  test "game index" do
    get games_url
    assert_response 200
  end

  test "game index with data" do
    create(:port).game
    get games_url
    assert_response 200
  end

  test "game show" do
    g = create(:port).game
    get game_url(g)
    assert_response 200
  end


  test "game index with data signed in" do
    sign_in
    g = create(:port).game
    get games_url
    assert_response 200
  end

  test "game show signed in" do
    sign_in
    g = create(:port).game
    get game_url(g)
    assert_response 200
  end
end