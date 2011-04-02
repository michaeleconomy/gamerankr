require "amazon/ecs"


Rails.application.config.after_initialize do
  begin
    key_id = Secret[:aWS_access_key_id]
    secret = Secret[:aWS_secret_key]
  rescue Exception => e
    Rails.logger.info "error getting secrets: #{e}\n#{e.backtrace.join("\n")}"
  end
  Amazon::Ecs.options = {:aWS_access_key_id => key_id,
    :aWS_secret_key => secret}
end
