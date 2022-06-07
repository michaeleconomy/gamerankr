Rails.application.config.after_initialize do
  ActionMailer::Base.smtp_settings = {
    :address        => 'email-smtp.us-west-2.amazonaws.com',
    :port           => '587',
    :authentication => :login,
    :user_name      => Secret['aws_ses_username'],
    :password       => Secret['aws_ses_password'],
    :domain         => 'gamerankr.com',
    :enable_starttls_auto => true
  }
  ActionMailer::Base.delivery_method = :smtp
end

