Rails.application.config.after_initialize do
  ActionMailer::Base.register_interceptor BouncedEmailInterceptor
  unless Rails.env.production?
    ActionMailer::Base.register_interceptor(SandboxEmailInterceptor)
  end
end