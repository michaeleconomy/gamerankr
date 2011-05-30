class MainController < ApplicationController
  
  def index
    @hot_games = Port.
      limit(30).
      order('games.rankings_count desc').
      includes(:game).with_image.shuffle
    @rankings = Ranking.limit(5).order('id desc').with_review  
    get_rankings
    @genres = Genre.limit(20).order('name')
  end
  
  def fb_test
    
  end
  
end
