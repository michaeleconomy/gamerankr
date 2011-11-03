require "amazon/ecs"


Rails.application.config.after_initialize do
  begin
    key_id = Secret[:aWS_access_key_id]
    secret = Secret[:aWS_secret_key]
  rescue Exception => e
    Rails.logger.info "error getting secrets: #{e}\n#{e.backtrace.join("\n")}"
  end
  Amazon::Ecs.options = {:AWS_access_key_id => key_id,
    :AWS_secret_key => secret, :associate_tag => "gamerankr-20"}
end
