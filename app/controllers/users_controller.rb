class UsersController < ApplicationController
  before_filter :load_user, :only => [:show, :edit, :update, :destroy]
  
  def index
    @users = User.where("rankings_count > 0").paginate :page => params[:page]
  end
  
  def show
    @rankings = @user.rankings.includes(:game, :port, :ranking_shelves => :shelf)
    @rankings = @rankings.paginate :page => params[:page]
    get_rankings
  end
end
