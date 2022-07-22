class RankingShelvesController < ApplicationController
  before_action :require_sign_in, :except => [:show]
  before_action :load_ranking_shelf, :only => [:show, :destroy]
  before_action :require_owner, :only => [:destroy]
  
  def show
    redirect_to @ranking_shelf.shelf
  end
  
  def create
    @ranking_shelf = RankingShelf.new(params[:ranking_shelf])
    if @ranking_shelf.shelf && @ranking_shelf.shelf.user_id != current_user.id
      respond_to do |format|
        format.js do
          render json:"not your shelf", status: 400
        end
      end
    end
    
    if @ranking_shelf.save
      respond_to do |format|
        format.js do
          render json:@ranking_shelf
        end
      end
      return
    end
    
    respond_to do |format|
      format.js do
        render json:@ranking_shelf.errors.full_messages, status: 400
      end
    end
  end
  
  def destroy
    
  end
  
  private
  
  def require_owner
    if @ranking_shelf.shelf.user_id != current_user.id
      respond_to do |format|
        format.js do
          render plain: "not your shelf", status: 400
        end
      end
      return false
    end
    
    true
  end
end
