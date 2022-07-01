class MainController < ApplicationController

  def index
    @platforms = Platform.featured

    @hot_games = Game.popular_ports
    @rankings = Ranking.recent_reviews.
      limit(10).
      includes(:shelves, :user, :port => [:additional_data, :game, :platform])
    get_rankings
    check_email_warnings
  end

  def auto_sign_in_page
    if signed_in?
      redirect_to "/"
    end
  end

  private

  def check_email_warnings
    if signed_in?
      if current_user.emails.first
        if current_user.emails.first.bounced?
          @bounce_warning = true
        end
        return
      end

      @no_email = true
    end
  end
    
end
