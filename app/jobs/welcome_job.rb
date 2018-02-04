class WelcomeJob
  include SuckerPunch::Job
  workers 1

  def perform(user_id)
    ActiveRecord::Base.connection_pool.with_connection do
      user = User.find(user_id)
      return unless user.email
      WelcomeMailer.welcome(user).deliver
    end
  end
end