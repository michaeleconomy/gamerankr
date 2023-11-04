class AuthMailer < ApplicationMailer
  
  def reset_password(user)
    @to_user = user
    @reset_url = reset_password_url code: user.password_reset_request.code

    mail(to: user.email, subject: "GameRankr - Reset Password")
  end

  def verify(user)
    @to_user = user
    @verify_url = verify_url code: user.verification_code
    @report_incorrect_url = report_incorrect_email_url code: user.verification_code

    mail(to: user.email, subject: "GameRankr - Verify Email Address")
  end
end