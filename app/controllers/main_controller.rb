class MainController < ApplicationController

  def index
    @platforms = Platform.featured

    @hot_games = Game.popular_ports.includes(:additional_data, :game, :platform)
    @rankings = Ranking.recent_reviews.
      limit(10).
      includes(:shelves, :user, :port => [:additional_data, :game, :platform])
    get_rankings
    if signed_in?
      if current_user.emails.first.bounced?
        @bounce_warning = true
      end
    end
  end
    
end
