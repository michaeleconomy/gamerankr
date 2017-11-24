class MainController < ApplicationController
  
  def index
    @hot_games = Port.
      limit(30).
      order('games.rankings_count desc').
      includes(:game, :platform).shuffle
    @rankings = Ranking.
      limit(5).
      includes(:shelves, :user, :port => :game).
      order('rankings.id desc').
      with_review
    get_rankings
  end
  
  def fb_test
    
  end
  
end
