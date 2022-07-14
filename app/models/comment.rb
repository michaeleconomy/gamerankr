class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :resource, polymorphic: true, counter_cache: true

  validates_presence_of :user, :resource

  validates_length_of :comment, in: 1..4000
  validates_inclusion_of :resource_type, in: ["Ranking"]

  after_create_commit :do_notify

  self.per_page = 5

  def do_notify
    concerned_user_ids = resource.comments.pluck(Arel.sql("distinct(user_id)"))
    concerned_user_ids << resource.user_id
    concerned_user_ids.uniq!
    concerned_user_ids.delete(user_id)
    concerned_users = User.where(id: concerned_user_ids)
    concerned_users.each do |user|
      next unless user.recieves_emails? && user.comment_notification_email
      Rails.logger.info "sending CommentNotificationMailer email to #{user.to_param}"
      CommentNotificationMailer.comment_notification(user, self).deliver_later
    end
  end
end
