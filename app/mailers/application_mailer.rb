class ApplicationMailer < ActionMailer::Base
  layout 'mail_layout'
  helper ApplicationHelper
  default :from => "GameRankr <no-reply@gamerankr.com>"
end