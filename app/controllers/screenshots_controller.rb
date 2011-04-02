class ScreenshotsController < ApplicationController
  before_filter :load_game, :only => [:game]
  
  
  def game
    @screenshots = []
  end
end
