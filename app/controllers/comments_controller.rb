class CommentsController < ApplicationController
  before_action :require_sign_in

  before_action :load_comment, :only => [:destroy]  
  
  def notify
    href = params[:href]
    params[:comment_id]
    params[:parent_comment_id]
    message = params[:message]
    
    notify_user = nil
    item = nil
    if href =~ /\/rankings\/(\d+)$/
      ranking_id = $1
      item = Ranking.find_by_id(ranking_id)
      if item
        notify_user = item.user
      end
    else
      logger.warn "unrecognized url: #{href}"
    end
    
    if item && message && notify_user && notify_user.id != current_user.id
      logger.info "sending message to item owner"
      CommentNotificationMailer.comment_notification(item, notify_user, current_user, message, href).deliver
    end
    
    render :plain => "thanks for letting us know!"
  end


  def create
    @comment = Comment.new(params.require(:comment).permit(:resource_id, :resource_type, :comment))
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
