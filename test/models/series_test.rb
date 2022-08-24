require "test_helper"

class SeriesTest < ActiveSupport::TestCase

  test "set blank" do
    g = create :game
    assert GameSeries.count == 0
    assert Series.count == 0

    g.set_series ["foo", "foo2"]

    assert GameSeries.count == 2
    assert Series.count == 2
  end

  test "set existing" do
    g = create :game
    assert GameSeries.count == 0
    assert Series.count == 0

    g.set_series ["foo", "foo2"]

    assert GameSeries.count == 2
    assert Series.count == 2

    g.reload
    g.set_series ["foo3", "foo2"]

    assert GameSeries.count == 2
    assert Series.count == 3
  end
end
