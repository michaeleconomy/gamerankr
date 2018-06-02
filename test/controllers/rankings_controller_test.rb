require 'test_helper'

class RankingsControllerTest < ActionDispatch::IntegrationTest
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
end