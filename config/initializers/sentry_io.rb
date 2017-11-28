Raven.configure do |config|
  if Secret["sentry_io"]
    config.dsn = Secret["sentry_io"]
  end
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end