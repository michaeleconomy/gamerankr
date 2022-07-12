class BouncedEmailInterceptor
  def self.delivering_email(message)
    if User.where(email: message.to).where("bounce_count > 0").exists?
      Rails.logger.info "not emailing #{message.to} - email has bounced in the past"
      message.perform_deliveries = false
    end
  end
end
