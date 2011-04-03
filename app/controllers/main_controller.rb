class MainController < ApplicationController
  
  def index
    @hot_games = Port.limit(30).order('id desc').with_image
    @rankings = Ranking.limit(5).order('id desc').with_review
  end
  
end
