class MainController < ApplicationController
  
  def index
    port_ids = Ranking.where("created_at > ?", 3.months.ago).group(:game_id).order("count(1) desc").limit(30).pluck("min(port_id)")
    @hot_games = Port.where(id: port_ids).includes(:additional_data, :game, :platform)
    @rankings = Ranking.
      limit(10).
      includes(:shelves, :user, :port => [:additional_data, :game, :platform]).
      order('rankings.id desc').
      with_review
    get_rankings
    if signed_in?
      if current_user.emails.first.bounced?
        @bounce_warning = true
      end
    end
  end
  
  def fb_test
    
  end
  
end
