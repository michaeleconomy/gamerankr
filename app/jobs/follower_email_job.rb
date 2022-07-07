class FollowerEmailJob
  include SuckerPunch::Job
  workers 1

  def perform(follow_id)
    ActiveRecord::Base.connection_pool.with_connection do
      follow = Follow.find(follow_id)
      return unless follow
      user = follow.following
      return unless user && user.recieves_emails? && user.new_follower_email
      FollowerMailer.follower(follow).deliver
    end
  end
end