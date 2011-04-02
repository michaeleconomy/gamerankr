class RankingsController < ApplicationController
  before_filter :require_sign_in, :except => [:show, :index, :user]
  before_filter :load_ranking, :only => [:show, :edit, :update, :destroy]
  before_filter :load_user, :only => [:user]
  before_filter :load_shelf, :only => [:my_shelf]
  
  before_filter :ensure_owner, :only => [:edit, :update, :destroy]
  
  
  def mine
    @rankings = current_user.rankings.includes(:port, :game).paginate(:page => params[:page])
    @shelves = current_user.shelves
  end
  
  def my_shelf
    @rankings = @shelf.rankings.includes(:port, :game).paginate(:page => params[:page])
    @shelves = current_user.shelves
  end
  
  def user
    @shelves = @user.shelves
    @rankings = @user.rankings.includes(:port, :game).paginate(:page => params[:page])
    get_rankings
  end
  
  def show
    redirect_to @ranking.game
  end
  
  def create
    @ranking = Ranking.new params[:ranking]
    @ranking.user_id = current_user.id
    if @ranking.save
      respond_to do |format|
        format.js do
          render :json => @ranking
          return
        end
      end
    end
    
    respond_to do |format|
      format.js do
        render :json => @ranking.errors.full_messages.to_sentence, :status => 400
      end
    end
  end
  
  def edit
    @port = @ranking.port
    @ranking.attributes = params[:ranking]
    render :action => 'edit'
  end
  
  def update
    if @ranking.update_attributes params[:ranking]
      respond_to do |format|
        format.html do
          flash[:notice] = "Ranking edited."
          redirect_to @ranking
        end
        format.js do
          render :json => @ranking
        end
      end
      return
    end
    
    respond_to do |format|
      format.html do
        edit
      end
      format.js do
        render :json => @ranking.errors.full_messages.to_sentence, :status => 400
      end
    end
  end
  
  def destroy
    @ranking.destroy
    respond_to do |format|
      format.html do
        flash[:notice] = "Rating destroyed."
        redirect_to @ranking.port
      end
      format.all do
        render :text => "Rating destroyed"
      end
    end
  end
  
  private
  
  def ensure_owner
    if @ranking.user_id != current_user.id
      respond_to do |format|
        format.html do
          flash[:notice] = "Not your review"
          redirect_to "/"
        end
        format.all do
          render :text => "review not yours", :status => 400
        end
      end  
      return false
    end
    true
  end
end
