class ContactJob
  include SuckerPunch::Job
  workers 1

  def perform(user_id, hash)
    ActiveRecord::Base.connection_pool.with_connection do
      ContactMailer.contact(user_id, hash).deliver
    end
  end
end