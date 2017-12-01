class MainController < ApplicationController

  FEATURED_PLATFORMS = ["PlayStation 4", "Xbox One", "Nintendo Switch", "PC", "Mac", "iPhone", "Android"]
  
  def index
    platforms_raw = Platform.where(name: FEATURED_PLATFORMS).all.index_by(&:name)
    @platforms = FEATURED_PLATFORMS.collect{|p| platforms_raw[p]}
    if @platforms.size != FEATURED_PLATFORMS.size
      logger.warn "not all FEATURED_PLATFORMS were found!"
    end
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
