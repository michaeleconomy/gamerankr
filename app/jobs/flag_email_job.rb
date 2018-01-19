class FlagEmailJob
  include SuckerPunch::Job
  workers 1

  def perform(user_id, resource_id, resource_type, text)
    ActiveRecord::Base.connection_pool.with_connection do
      ContactMailer.flag(user_id, resource_id, resource_type, text).deliver
    end
  end
end