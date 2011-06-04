class RankingsController < ApplicationController
  
  include RankingsSorting
  before_filter :require_sign_in, :except => [:show, :index, :user]
  before_filter :load_ranking, :only => [:show, :edit, :update, :destroy]
  before_filter :load_user, :only => [:user]
  before_filter :load_shelf, :only => [:my_shelf]
  
  before_filter :ensure_owner, :only => [:edit, :update, :destroy]
  
  def mine
    get_sort
    get_view
    @rankings = current_user.rankings.
      includes(:game, :port => :platform).
      order(COLUMNS[@sort] + @sort_order.to_s).
      paginate(:page => params[:page])
    @shelves = current_user.shelves
  end
  
  def my_shelf
    get_sort
    get_view
    @rankings = @shelf.rankings.
      includes(:game, :port => :platform).
      order(COLUMNS[@sort] + @sort_order.to_s).
      paginate(:page => params[:page])
    @shelves = current_user.shelves
  end
  
  def user
    get_sort
    get_view
    @shelves = @user.shelves
    @rankings = @user.rankings.
      includes(:game, :port => :platform).
      order(COLUMNS[@sort] + @sort_order.to_s).
      paginate(:page => params[:page])
    get_rankings
  end
  
  def show
    @port = @ranking.port
    @user = @ranking.user
    @comment_moderator = @user.facebook_user.uid
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
    @ranking.post_to_facebook = true if @ranking.post_to_facebook.nil?
    render :action => 'edit'
  end
  
  def update
    @user = @ranking.user
    if @ranking.update_attributes params[:ranking]
      @port = @ranking.port
      respond_to do |format|
        format.html do
          if @ranking.post_to_facebook == "1"
            r_url = ranking_url(@ranking)
            shelves = @ranking.shelves
            caption = "Added to #{"shelf".pluralize_optionally(shelves.size)}: #{shelves.collect(&:name).join(", ")}"
            next_url = url_for :host => "www.facebook.com",
              :controller => "dialog",
              :action => "feed",
              :app_id => Secret[:facebook_app_id],
              :link => r_url,
              :picture => @port.resized_amazon_image_url("SX120"),
              :name => "#{@user.first_name}'s review of #{@port.title}",
              :caption => caption,
              :description => @ranking.review,
              :redirect_uri => r_url# ,
              #               :actions => [{:name => "see review", :link => r_url},
              #                  {:name => "see game", :link => port_url(@port)}].to_json
          else
            next_url = @port
          end
          flash[:notice] = "Ranking edited."
          redirect_to next_url
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
