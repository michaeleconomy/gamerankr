Rails.application.config.after_initialize do
  Sentry.init do |config|
    if Secret["sentry_io"]
      config.dsn = Secret["sentry_io"]
    end
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
    config.enabled_environments = %w[production staging]
  end
end