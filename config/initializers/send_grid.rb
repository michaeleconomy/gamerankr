# ActionMailer::Base.smtp_settings = {
#   :address        => 'smtp.sendgrid.net',
#   :port           => '587',
#   :authentication => :plain,
#   :user_name      => Secret['sendgrid_username'],
#   :password       => Secret['sendgrid_password'],
#   :domain         => 'gamerankr.com',
#   :enable_starttls_auto => true
# }
# ActionMailer::Base.delivery_method = :smtp