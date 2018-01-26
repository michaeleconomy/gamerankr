ActionMailer::Base.register_interceptor BouncedEmailInterceptor
ActionMailer::Base.register_interceptor NoEmailInterceptor
unless Rails.env.production?
  ActionMailer::Base.register_interceptor(SandboxEmailInterceptor)
end