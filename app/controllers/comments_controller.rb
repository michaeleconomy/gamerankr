class CommentsController < ApplicationController
  before_action :require_sign_in, :except => [:list]

  before_action :load_comment, :only => [:destroy]

  ALLOWED_RESOURCES = {
    ranking: Ranking
  }

  def index
    @resource = Ranking.where(id: params[:ranking_id]).first

    if !@resource
      respond_to do |format|
        format.js do
          render :json => "resource_not_found", :status => 404
        end
      end
      return
    end

    @comments = @resource.comments.order("id desc").paginate(:page => params[:page])
  end

  def create
    @comment = Comment.new(params.require(:comment).
      permit(:resource_id, :resource_type, :comment))
    @comment.user_id = current_user.id
    if @comment.save
      respond_to do |format|
        format.js do
          render :json => @comment
          return
        end
      end
    end
    
    respond_to do |format|
      format.js do
        render :json => @comment.errors.full_messages.to_sentence, :status => 400
      end
    end
  end

  def destroy
    if @comment.user_id != current_user.id
      respond_to do |format|
        format.html do
          flash[:notice] = "Comment deleted."
          redirect_to @comment.resource
        end
        format.all do
          render :plain => "Comment deleted"
        end
      end
    end
    @comment.destroy
    respond_to do |format|
      format.html do
        flash[:notice] = "Comment deleted."
        redirect_to @comment.resource
      end
      format.all do
        render :plain => "Comment deleted"
      end
    end
  end
end
