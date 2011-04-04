class GamesController < ApplicationController
  before_filter :load_game, :only => [:show]
  
  def show
    @port = @game.ports.first
    unless @port
      flash[:error] = "Game not longer exists."
      redirect_to "/"
      return
    end
    @all_rankings = @game.rankings.paginate :page => params[:page]
    get_rankings [@game]
    if signed_in?
      @friend_rankings = @game.rankings.find_all_by_user_id(friend_ids)
      @all_rankings -= @friend_rankings
      @all_rankings -= @user_rankings.values
    end
    @ranking = @user_rankings.values.first
  end
end
