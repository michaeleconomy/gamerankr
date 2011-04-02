class GamesController < ApplicationController
  before_filter :load_game, :only => [:show]
  
  def show
    @port = @game.ports.first
    unless @port
      flash[:error] = "Game not longer exists."
      redirect_to "/"
      return
    end
    if signed_in?
      @friend_rankings = @game.rankings.find_all_by_user_id(friend_ids)
    end
    @all_rankings = @game.rankings.paginate :page => params[:page]
    get_rankings [@game]
    @ranking = @user_rankings.values.first
  end
end
