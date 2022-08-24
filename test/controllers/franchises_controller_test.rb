require "test_helper"

class FranchisesControllerTest < ActionDispatch::IntegrationTest

  test "show" do
    g = create(:port).game
    g.set_franchises ["foo"]

    assert Franchise.count == 1

    f = Franchise.first
    get franchise_url(f)
    assert_response 200
    assert_select "a", g.title
  end
end
