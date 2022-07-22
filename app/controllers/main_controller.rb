class MainController < ApplicationController
  before_action :require_sign_in, except: [:index]

  def index
    @hot_games = Game.popular_ports
    @rankings = Ranking.recent_reviews.
      limit(10).
      includes(:shelves, :user, port: [:additional_data, :game, :platform])
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
      if current_user.email
        if current_user.email_bounced?
          @bounce_warning = true
        end
        return
      end

      @no_email = true
    end
  end
    
end
