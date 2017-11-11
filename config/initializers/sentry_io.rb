Raven.configure do |config|
  config.dsn = Secret["sentry_io"]
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end