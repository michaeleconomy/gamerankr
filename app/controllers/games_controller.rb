class GamesController < ApplicationController
  before_filter :load_game, :only => [:show, :edit, :update, :destroy]
  before_filter :require_admin, :only => [:edit, :update, :destroy]
  
  def index
    @games = Game.paginate :page => params[:page], :order => 'title'
  end
  
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
  
  
  def edit
    @game.attributes = params[:game]
  end
  
  def update
    if @game.update_attributes(params[:game])
      redirect_to :game
      return
    end
    render :action => 'edit'
  end
  
  def destroy
    @game.destroy
    flash[:notice] = "Game destroyed"
    redirect_to "/"
  end
end
