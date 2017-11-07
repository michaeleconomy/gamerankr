class ScreenshotsController < ApplicationController
  before_action :load_game, :only => [:game]
  
  
  def game
    @screenshots = []
  end
end
