class ApplicationMailer < ActionMailer::Base
  layout 'mail_layout'
  add_template_helper(ApplicationHelper)
  default :from => "GameRankr <no-reply@gamerankr.com>"
end