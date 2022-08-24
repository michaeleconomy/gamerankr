require 'test_helper'

class GameGenreTest < ActiveSupport::TestCase
  
  test "add genre" do
    g = create :game
    assert GameGenre.count == 0
    assert Genre.count == 0

    g.add_genre "foo"

    assert GameGenre.count == 1
    assert Genre.count == 1
  end


  test "add genre reuses existing" do
    g = create :game
    assert GameGenre.count == 0

    genre = create :genre
    assert Genre.count == 1

    g.add_genre genre.name

    assert GameGenre.count == 1
    assert Genre.count == 1
  end


  test "set genre blank" do
    g = create :game
    assert GameGenre.count == 0
    assert Genre.count == 0

    g.set_genres ["foo", "foo2"]

    assert GameGenre.count == 2
    assert Genre.count == 2
  end

  test "set genre existing" do
    g = create :game
    assert GameGenre.count == 0
    assert Genre.count == 0

    g.set_genres ["foo", "foo2"]

    assert GameGenre.count == 2
    assert Genre.count == 2

    g.reload
    g.set_genres ["foo3", "foo2"]

    assert GameGenre.count == 2
    assert Genre.count == 3
  end
end
