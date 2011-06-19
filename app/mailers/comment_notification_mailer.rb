class CommentNotificationMailer < ActionMailer::Base
  layout 'mail_layout'
  default :from => "GameRankr <no-reply@gamerankr.com>"
  
  def comment_notification(item, to_user, comment_user, message, url)
    @item = item
    @to_user = to_user
    @comment_user = comment_user
    @message = message
    @url = url
    mail(:to => to_user.email,
         :subject => "Comment on your review of #{item.game.title}")
  end
end
