class Secret < ActiveRecord::Base
  
  def self.[](key)
    secret = find_by_key(key)
    secret ? secret.value : nil
  rescue Exception => e
    logger.error "couldn't load key #{key}\n#{e}\n#{e.backtrace}"
    nil
  end
  
  def self.[]=(key, value)
    secret = where(key: key).first_or_create
    secret.value = value
    secret.save
    value
  rescue Exception => e
    logger.error "couldn't set key #{key}\n#{e}\n#{e.backtrace}"
    nil
  end
end
