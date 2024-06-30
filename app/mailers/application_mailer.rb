class ApplicationMailer < ActionMailer::Base
  layout 'mail_layout'
  helper ApplicationHelper
  default from: "GameRankr <no-reply@gamerankr.com>"

  rescue_from "Net::SMTPSyntaxError" do |err|
    logger.info "Net::SMTPSyntaxError: #{err}"
  end
end