
Rails.application.config.middleware.use OmniAuth::Builder do
  
  Rails.application.config.after_initialize do
    begin
      app_id = Secret[:facebook_app_id]
      secret = Secret[:facebook_app_secret]
    rescue Exception => e
      Rails.logger.info "error getting secrets: #{e}\n#{e.backtrace.join("\n")}"
    end  
    provider :facebook, app_id, secret
  end
end