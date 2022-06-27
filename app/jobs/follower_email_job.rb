class FollowerEmailJob
  include SuckerPunch::Job
  workers 1

  def perform(follow_id)
    ActiveRecord::Base.connection_pool.with_connection do
      follow = Follow.find(follow_id)
      return unless follow && follow.following && follow.following.new_follower_email
      FollowerMailer.follower(follow).deliver
    end
  end
end