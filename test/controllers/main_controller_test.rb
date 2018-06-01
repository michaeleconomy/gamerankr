require 'test_helper'

class MainControllerTest < ActionDispatch::IntegrationTest
  test "home page no data" do
    get "/"
    assert_response 200
  end

  test "signed in home page no data" do
    get "/"
    assert_response 200
  end
end
