class CommentsController < ApplicationController
  before_action :require_sign_in
  
  
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
end
