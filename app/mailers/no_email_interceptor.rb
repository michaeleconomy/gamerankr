class NoEmailInterceptor
  def self.delivering_email(message)
    if !message.to || message.to == ""
      Rails.logger.info "not emailing user without email address"
      message.perform_deliveries = false
    end
  end
end
