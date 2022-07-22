class AuthController < ApplicationController
  before_action :require_sign_in, except: [
  	:sign_in, :do_sign_in,
    :reset_password, :do_reset_password,
    :reset_password_request, :do_reset_password_request,
    :verify,
    :verification_required,
    :create_account, :do_create_account,
  ]

  before_action :verify_password_reset_code, only: [:reset_password, :do_reset_password]

  def sign_in
    if signed_in?
      redirect_to "/"
      return
    end
  end

  def do_sign_in
    if signed_in?
      redirect_to "/"
      return
    end
    @user = User.where(email: params[:email]).first
    if !@user
      logger.info "invalid email"
      flash.now[:error] = "Sign in information invalid."
      render action: "sign_in"
      return
    end

    if !@user.authenticate params[:password]
      logger.info "invalid password"
      flash.now[:error] = "Sign in information invalid."
      render action: "sign_in"
      return
    end

    if !@user.verified?
      redirect_to verification_required_path
      return
    end
    sign_user_in @user

    flash[:notice] = "Welcome back #{@user.first_name}!"
  	redirect_to "/"
  end

  def create_account
  end

  def do_create_account
    @user = User.new
    @user.real_name = params[:real_name]
    @user.password = params[:password]
    @user.email = params[:email]
    @user.verification_code = SecureRandom.alphanumeric(64)
    if !@user.save
      render action: "create_account"
      return
    end


    AuthMailer.verify(@user).deliver_later

    redirect_to verification_required_path
  end

  def sign_out
  end

  def do_sign_out
    if cookies.signed[:lg]
      current_user.web_authorizations.where(uid: cookies.signed[:lg]).delete_all
      cookies.delete :lg
    end
    session[:user_id] = nil
    cookies.delete :autosignin
  	flash[:error] = "Signed Out."
  	redirect_to "/"
  end

  def reset_password_request
  end

  def do_reset_password_request
    email = params[:email]
    if !User.email_regex.match?(email)
      flash.now[:error] = "Invalid email address provided: #{email}"
      render action: "reset_password_request"
      return
    end

    @user = User.where(email: email).first
    if !@user
      flash.now[:error] = "No account found for #{email}. Do you want to create an account?"
      render action: "reset_password_request"
      return
    end
    if !@user.password_reset_request
      @user.build_password_reset_request
    end
    @user.password_reset_request.code = SecureRandom.alphanumeric(64)
    @user.password_reset_request.save!
    AuthMailer.reset_password(@user).deliver_later

    flash[:notice] = "A password reset email has been sent to: #{email}. " +
      "Check your inbox and follow the instructions"
    redirect_to "/"
  end

  def reset_password
    
  end

  def do_reset_password
    password = params[:password]
    if password != params[:password_confirm]
      flash.now[:error] = "Passwords do not match"
      render action: "reset_password"
      return
    end

    @user = @reset_request.user

    @user.password = password
    @user.save!
    @reset_request.destroy
    @user.web_authorizations.delete_all
    ios = @user.ios_authorization
    if ios
      ios.destroy
    end

    if !@user.verified?
      do_verify @user
      redirect_to welcome_path
      return
    end

    sign_user_in(@user)
    flash[:notice] = "Password reset and you've been signed in.  Welcome back!"
    redirect_to "/"
  end

  def verify
    if !params[:code]
      flash[:error] = "Verification could not be performed."
      redirect_to "/"
      return
    end

    @user = User.where(verification_code: params[:code], verified_at: nil).first
    if !@user
      flash[:error] = "Verification could not be performed."
      redirect_to "/"
      return
    end
    do_verify @user
    redirect_to welcome_path
  end

  def verification_required
    if signed_in?
      redirect_to "/"
      return
    end
  end

  private

  def verify_password_reset_code
    @reset_request = PasswordResetRequest.get(params[:code])
    if !@reset_request
      flash[:error] = "Request has expired.  Please try resetting your password again."
      redirect_to reset_password_request_path
      return false
    end

    true
  end

  def do_verify(user)
    if !user.verified?
      user.verified_at = Time.now
      user.verification_code = nil
      user.save!
      WelcomeMailer.welcome(user).deliver_later
    end
    sign_user_in user
  end

  def sign_user_in(user)
    self.current_user = user
    token = SecureRandom.alphanumeric(64)
    user.web_authorizations.create! uid: token
    cookies.signed.permanent[:lg] = token
  end
end
