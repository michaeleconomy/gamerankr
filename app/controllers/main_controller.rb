class MainController < ApplicationController
  
  def index
    @hot_games = Port.
      limit(29).
      order('games.rankings_count desc').
      includes(:game).with_image
    @rankings = Ranking.limit(5).order('id desc').with_review
    @genres = Genre.limit(20).order('game_genres_count desc')
  end
  
end
