require "amazon/ecs"


Rails.application.config.after_initialize do
  Amazon::Ecs.options = {:aWS_access_key_id => Secret[:aWS_access_key_id],
    :aWS_secret_key => Secret[:aWS_secret_key]}
end
