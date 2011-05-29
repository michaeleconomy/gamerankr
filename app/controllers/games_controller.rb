class GamesController < ApplicationController
  before_filter :load_game, :only => [:show]
  
  def show
    @port = @game.ports.first
    unless @port
      flash[:error] = "Game not longer exists."
      redirect_to "/"
      return
    end
    @developers = @game.developers.uniq
    @designers = @game.designers
    @publishers = @game.publishers.uniq
    @platforms = @game.platforms.uniq
    @all_rankings = @game.rankings.paginate :page => params[:page]
    get_rankings [@game]
    if signed_in?
      @friend_rankings = @game.rankings.find_all_by_user_id(friend_ids)
      @all_rankings.delete_if do |r|
        @friend_rankings.include?(r)
      end
      @all_rankings.delete_if do |r|
        r.user_id == current_user.id
      end
    end
    @ranking = @user_rankings.values.first
  end
end
