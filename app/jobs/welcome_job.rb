class WelcomeJob
  include SuckerPunch::Job
  workers 1

  def perform(user_id)
    ActiveRecord::Base.connection_pool.with_connection do
      WelcomeMailer.welcome(User.find(user_id)).deliver
    end
  end
end