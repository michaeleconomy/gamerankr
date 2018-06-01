require 'test_helper'

class GameTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "game create" do
    port = create :port
    assert port
    assert port.game
    assert port.platform
    
    assert port.additional_data
    assert port.resized_image_url("SX50")
  end
end
