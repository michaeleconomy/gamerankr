require "test_helper"

class PublishersControllerTest < ActionDispatch::IntegrationTest

  test "index" do
    p = create :publisher

    get publishers_url
    assert_response 200
    assert_select "a", p.name

  end

  test "show" do
    g = create(:port).game
    g.set_publishers ["foo"]

    assert Publisher.count == 1

    f = Publisher.first
    get publisher_url(f)
    assert_response 200
    assert_select "a", g.title
  end
end
