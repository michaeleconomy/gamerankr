class SessionsController < ApplicationController

  class MultipleAccountsError < StandardError
  end

  def create
    auth_info = request.env['omniauth.auth']
    if auth_info['provider'] != "facebook"
      raise "unsupported auth provider: #{auth_info['provider']}"
    end
    begin
      sign_in_facebook(
        real_name: auth_info['info']['name'],
        email: auth_info['info']['email'],
        uid: auth_info['uid'],
        token: auth_info["credentials"]["token"])
    rescue MultipleAccountsError
      flash[:error] = "Could not sign you in with Facebook. There is a different account tied to that email address."
      redirect_to "/"
      return
    end
    
    cookies.permanent[:autosignin] = true
    redirect = session.delete(:jump_to) || "/"
    if @new_user
      redirect_to welcome_path
      return
    end

    flash[:notice] = "Welcome back, #{current_user.real_name}."

    redirect_to session.delete(:jump_to) || "/"
  end

  def mobile_login
    user = nil
    if params[:fb_auth_token]
      fb_user = FbGraph2::User.new('me',
        access_token: params[:fb_auth_token]).
        fetch(fields: [:name, :email])
      # This may error out, but would be caught in application controller
      begin
        user = sign_in_facebook(
          real_name: fb_user.name,
          email: fb_user.email,
          uid: fb_user.id,
          token: params[:fb_auth_token])
      rescue MultipleAccountsError
        render json: "Cannot sign in, multiple accounts tied to that email.", status: 400
        return
      end
    elsif params[:email] && params[:password]
      user = User.find_by_email(params[:email])
      if !user
        render json: "Invalid Email", status: 404
        return
      end
      if !user.authenticate params[:password]
        render json: "Invalid Password", status: 400
        return
      end
      if !user.verified?
        if !params[:no_verify_email]
          AuthMailer.verify(user).deliver_later
          session[:last_verification_email_at] = Time.now
          session[:unverified_email] = params[:email]
        end
        render json: {unverified: "yes"}, status: 200
        return
      end
    else
      render json: "Invalid Request", status: 400
      return
    end

    ios_authorization = user.ios_authorization
    if !ios_authorization
      ios_authorization = user.create_ios_authorization!(
        provider: 'gamerankr-ios',
        uid: user.id,
        token: rand(2**512).to_s(36))
    end

    response = {token: ios_authorization.token, current_user_id: user.id.to_s}
    
    if @new_user
      response[:new_user] = true
    end

    render json: response
  end

  private

  def sign_in_facebook(real_name:, email:, uid:, token:)
    auth = Authorization.find_by_provider_and_uid("facebook", uid)
    user = nil
    if email
      user = User.where(email: email).first
      if user && !user.verified?
        logger.info "Existing unverified user found: #{user.id} - Deleting!"
        user.destroy!
        user = nil
      end
    end

    if auth
      if user && user.id != auth.user_id
        logger.info "MultipleAccountsError: uid attached to: #{auth.user_id} " +
          "but email attached to: #{user.id}"
        raise MultipleAccountsError
      end

      user = auth.user
      auth.update!(token: token)
      logger.info "signing in existing fb user: #{user.id}"
    else
      if user
        if user.facebook_user
          logger.info "MultipleAccountsError: email attached to: #{user.id} but " +
            "with different fb uid:#{user.facebook_user.uid} vs #{uid}"
          raise MultipleAccountsError
        end
        logger.info "signing in existing user - but adding facebook: #{user.id}"
      else
        logger.info "new user sign up user"
        user = User.create!(
          real_name: real_name,
          email: email,
          password: SecureRandom.alphanumeric(32),
          verified_at: Time.now)
        if email
          WelcomeMailer.welcome(user).deliver_later
        end
        @new_user = true
      end
      auth = user.authorizations.create(
        uid: uid,
        provider: "facebook",
        token: token)
    end

    self.current_user = user

    user
  end
end
