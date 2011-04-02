class MainController < ApplicationController
  
  def index
    @hot_games = Port.limit(100).order('id desc').with_image
    @rankings = Ranking.limit(5).order('id desc').with_review
  end
  
end
