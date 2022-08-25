require "test_helper"

class DeveloperTest < ActiveSupport::TestCase

  test "set blank" do
    g = create :game
    assert DeveloperGame.count == 0
    assert Developer.count == 0

    g.set_developers ["foo", "foo2"]

    assert DeveloperGame.count == 2
    assert Developer.count == 2
  end

  test "set existing" do
    g = create :game
    assert DeveloperGame.count == 0
    assert Developer.count == 0

    g.set_developers ["foo", "foo2"]

    assert DeveloperGame.count == 2
    assert Developer.count == 2

    g.reload
    g.set_developers ["foo3", "foo2"]

    assert DeveloperGame.count == 2
    assert Developer.count == 3
  end
end
