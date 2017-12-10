class CommentNotificationMailer < ApplicationMailer
  
  def comment_notification(to_user, comment)
    @resource = comment.resource
    @to_user = to_user
    @comment = comment
    if !@resource
      raise "comment_notification: resource could not be found"
    end
    if !@to_user
      raise "comment_notification: to_user could not be found"
    end
    if !@resource.is_a?(Ranking)
      raise "comment_notification: resource type of #{@resource.class} could not be handled"
    end

    @email_pref = :comment_notification_email
    subject = "#{@comment.user.real_name} commented on " +
      (@resource.user_id == to_user.id ? "your" : @resource.user.real_name + "'s") +
      " review of #{@resource.game.title}"
    mail(:to => to_user.email, :subject => subject)
  end
end
