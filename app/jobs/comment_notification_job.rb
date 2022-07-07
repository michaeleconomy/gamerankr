class CommentNotificationJob
  include SuckerPunch::Job
  workers 1


  def perform(comment_id)
    ActiveRecord::Base.connection_pool.with_connection do
      comment = Comment.where(id:comment_id).first
      if !comment
        Rails.logger.info "CommentNotificationJob:comment not found: #{comment_id}"
        return
      end

      concerned_user_ids = comment.resource.comments.pluck(Arel.sql("distinct(user_id)"))
      concerned_user_ids << comment.resource.user_id
      concerned_user_ids.uniq!
      concerned_user_ids.delete(comment.user_id)
      concerned_users = User.where(id: concerned_user_ids)
      concerned_users.each do |user|
        next unless user.recieves_emails? && user.comment_notification_email
        Rails.logger.info "sending CommentNotificationMailer email to #{user.to_param}"
        CommentNotificationMailer.comment_notification(user, comment).deliver
      end
    end
  end
end