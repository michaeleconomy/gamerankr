class WelcomeMailer < ApplicationMailer
  
  def welcome(to_user)
    @to_user = to_user
    if !@to_user
      raise "comment_notification: to_user could not be found"
    end

    mail(:to => @to_user.email, :subject => "Welcome to GameRankr")
  end
end
