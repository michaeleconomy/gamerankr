Rails.application.config.after_initialize do
  Sentry.init do |config|
    if Secret["sentry_io"]
      config.dsn = Secret["sentry_io"]
    end
  end
end