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


  test "search for game - multiple ports" do
    port = create :port
    game = port.game

    port2 = create :port
    port2.game = game
    port2.save!

    port3 = create :port
    port3.game = game
    port3.save!

    port4 = create :port
    port4.game = game
    port4.save!

    get search_url(:query => game.title)
    assert_response 200
    assert_select "a", game.title
  end

  test "search for alternate name" do
    port = create :port, title: "fff"
    game = port.game
    game.update! alternate_names: "fooboo"
    get search_url(query: "fooboo")
    assert_response 200
    assert_select "a", game.title
  end
end
