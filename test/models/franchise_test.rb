require "test_helper"

class FranchiseTest < ActiveSupport::TestCase

  test "set blank" do
    g = create :game
    assert GameFranchise.count == 0
    assert Franchise.count == 0

    g.set_franchises ["foo", "foo2"]

    assert GameFranchise.count == 2
    assert Franchise.count == 2
  end

  test "set existing" do
    g = create :game
    assert GameFranchise.count == 0
    assert Franchise.count == 0

    g.set_franchises ["foo", "foo2"]

    assert GameFranchise.count == 2
    assert Franchise.count == 2

    g.reload
    g.set_franchises ["foo3", "foo2"]

    assert GameFranchise.count == 2
    assert Franchise.count == 3
  end
end
