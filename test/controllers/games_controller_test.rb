require 'test_helper'

class GamesControllerTest < ActionDispatch::IntegrationTest
  test "game index" do
    get games_url
    assert_response 200
  end

  test "game index with data" do
    r = create_ranking
    get games_url
    assert_response 200
    assert_select "a", r.game.title
  end

  test "game show" do
    g = create(:port).game
    get game_url(g)
    assert_response 200
    assert_select "h1", g.title
  end

  test "game show full" do
    g = create(:port).game
    g.set_genres ["fps"]
    g.set_developers ["devguy"]
    g.set_publishers ["publishguy"]
    g.set_franchises ["franchiseguy"]
    g.set_series ["seriesguy"]
    
    g.set_alternate_names ["fooofooo"]
    g.save!


    get game_url(g)
    assert_response 200
    assert_select "h1", g.title
    assert_select "a", "fps"
    assert_select "a", "devguy"
    assert_select "a", "publishguy"
    assert_select "a", "franchiseguy"

    assert_body_contains "fooofooo"
  end

  test "game index with data signed in" do
    sign_in
    r = create_ranking
    get games_url
    assert_response 200
    assert_select "a", r.game.title
  end

  test "game show signed in" do
    sign_in
    g = create(:port).game
    get game_url(g)
    assert_response 200
    assert_select "h1", g.title
  end

  test "new_releases" do
    r = create_ranking
    r.game.update! initially_released_at: 1.week.ago
    get new_releases_url
    assert_response 200
    assert_select "a", r.game.title
  end

  test "recently_popular" do
    r = create_ranking
    get recently_popular_url
    assert_response 200
    assert_select "a", r.game.title
  end

  test "upcoming" do
    r = create_ranking
    r.game.update! initially_released_at: 1.year.from_now
    get upcoming_url
    assert_response 200
    assert_select "a", r.game.title
  end
end