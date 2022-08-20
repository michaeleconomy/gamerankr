require 'test_helper'

class RankingsControllerTest < ActionDispatch::IntegrationTest
  include RankingsSorting

  test "empty mine" do
    sign_in
    get my_games_url
    assert_response 200
  end

  test "mine" do
    u = sign_in
    r = create_ranking(user: u)
    get my_games_url
    assert_response 200
  end


  test "mine all sorts" do
    u = sign_in
    r = create_ranking(user: u)

    COLUMNS.each do |k, v|
      get my_games_url(sort: k)
      assert_response 200
    end
  end

  test "signed_out" do
    get my_games_url
    assert_response :redirect
  end


  test "create ranking" do
    u = sign_in
    p = create(:port)

    assert Ranking.count == 0    
    post rankings_url(format: 'js'),
      params: {
        ranking: {
          port_id: p.id,
          ranking_shelves_attributes: {
            0 => {shelf_id: u.shelves.first.id}
          }
        }
      }
    assert_response :success

    assert Ranking.count == 1
  end


  test "edit ranking get" do
    u = sign_in
    r = create_ranking(user: u)
    
    get edit_ranking_url(r)
    assert_response 200
  end

  test "edit ranking post" do
    u = sign_in
    r = create_ranking(user: u)
    assert r.ranking != 5
    put ranking_url(r, format: 'js'),
      params: {
        ranking: {
          ranking: 5
        }
      }
    assert_response 200
    r.reload
    assert r.ranking == 5
  end
end