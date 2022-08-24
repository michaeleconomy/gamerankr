require 'test_helper'

class GenreControllerTest < ActionDispatch::IntegrationTest
  test "index" do
    g = create :genre

    get genres_url
    assert_response 200

    assert_select "a", g.name
  end

  test "show" do
    g = create(:port).game
    genre = g.add_genre "foo"

    get genre_url(genre)
    assert_response 200

    assert_select "h1", genre.name
    assert_select "a", g.title
  end
end