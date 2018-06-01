require 'test_helper'

class SeriesControllerTest < ActionDispatch::IntegrationTest
  test "series index" do
    get series_index_url
    assert_response 200
  end

  test "series index with data" do
    create_series
    get series_index_url
    assert_response 200
  end

  test "series show" do
    s = create_series
    get series_url(s)
    assert_response 200
  end


  test "series index with data signed in" do
    sign_in
    create_series
    get series_index_url
    assert_response 200
  end

  test "series show signed in" do
    sign_in
    s = create_series
    get series_url(s)
    assert_response 200
  end

  def create_series
    s = create :series
    2.times do
      p = create :port
      s.games << p.game
    end
    assert GameSeries.count == 2
    s
  end
end
