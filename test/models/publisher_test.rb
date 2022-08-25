require "test_helper"

class PublisherTest < ActiveSupport::TestCase

  test "set blank" do
    g = create :game
    assert PublisherGame.count == 0
    assert Publisher.count == 0

    g.set_publishers ["foo", "foo2"]

    assert PublisherGame.count == 2
    assert Publisher.count == 2
  end

  test "set existing" do
    g = create :game
    assert PublisherGame.count == 0
    assert Publisher.count == 0

    g.set_publishers ["foo", "foo2"]

    assert PublisherGame.count == 2
    assert Publisher.count == 2

    g.reload
    g.set_publishers ["foo3", "foo2"]

    assert PublisherGame.count == 2
    assert Publisher.count == 3
  end
end
