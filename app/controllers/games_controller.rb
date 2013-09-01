class GamesController < ApplicationController
  before_filter :load_game, :only => [:show, :edit, :update, :destroy]
  before_filter :require_admin, :only => [:edit, :update, :destroy]
  
  def index
    @games = Game.paginate :page => params[:page], :order => 'title'
  end
  
  def show
    @ports = @game.ports
    if params[:port_id]
      @port = @ports.detect{|p| p.id == params[:port_id].to_i}
      if !@port
        flash[:error] = "That edition doesn't exist."
        redirect_to @game
        return
      end
    else
      @port = @ports.first
      unless @port
        flash[:error] = "Game not longer exists."
        redirect_to "/"
        return
      end
    end
    @series = @game.series
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
  end
  
  def update
    if @game.update_attributes(game_params)
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
  
  private
  
  def game_params
    params.require(:game).permit(:title, :initially_released_at, :initially_released_at_accuracy, :description)
  end
end
