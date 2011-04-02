
Rails.application.config.middleware.use OmniAuth::Builder do
  
  Rails.application.config.after_initialize do
    provider :facebook, Secret[:facebook_app_id], Secret[:facebook_app_secret]
  end
end