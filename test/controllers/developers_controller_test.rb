require "test_helper"

class DevelopersControllerTest < ActionDispatch::IntegrationTest

  test "index" do
    p = create :developer

    get developers_url
    assert_response 200
    assert_select "a", p.name

  end

  test "show" do
    g = create(:port).game
    g.set_developers ["foo"]

    assert Developer.count == 1

    f = Developer.first
    get developer_url(f)
    assert_response 200
    assert_select "a", g.title
  end
end
