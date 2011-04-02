class Secret < ActiveRecord::Base
  
  def self.[](key)
    secret = find_by_key(key)
    secret ? secret.value : nil
  end
  
  def self.[]=(key, value)
    secret = find_or_initialize_by_key(key)
    secret.value = value
    secret.save
    value
  end
end
