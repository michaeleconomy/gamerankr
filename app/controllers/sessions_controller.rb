class SessionsController < ApplicationController

  def create
    auth_info = request.env['omniauth.auth']
    auth = Authorization.find_by_provider_and_uid(auth_info['provider'], auth_info['uid'])
    if !auth
      # Create a new user or add an auth to existing user, depending on
      # whether there is already a user signed in.
      user = User.create!(real_name: auth_info['info']['name'], password: SecureRandom.alphanumeric(32))
      auth = user.authorizations.create(uid: auth_info['uid'], provider: auth_info['provider'])
    end
    # Log the authorizing user in.
    self.current_user = auth.user
    add_email auth_info['info']['email']
    
    auth.token = auth_info["credentials"]["token"]
    auth.save!
    cookies.permanent[:autosignin] = true

    flash[:notice] = "Welcome, #{current_user.real_name}."
    redirect_to session.delete(:jump_to) || "/"
  end

  def mobile_login
    fb_user = FbGraph2::User.new('me', access_token: params[:fb_auth_token]).
      fetch(fields: [:name, :email])
    # This may error out, but would be caught in application controller

    auth = Authorization.find_by_provider_and_uid("facebook", fb_user.id)
    if !auth
      user = User.create!(real_name: fb_user.name)
      auth = user.authorizations.create(uid: fb_user.id, provider: "facebook")
    end
    auth.token = params[:fb_auth_token]
    auth.save!

    user = auth.user

    # Log the authorizing user in.
    self.current_user = user
    add_email fb_user.email

    ios_authorization = user.ios_authorization
    if !ios_authorization
      ios_authorization = user.create_ios_authorization!(
        provider: 'gamerankr-ios',
        uid: user.id,
        token: rand(2**512).to_s(36))
    end

    render json: {token: ios_authorization.token, current_user_id: user.id.to_s}
  end

  private

  def add_email(email)
    return if !email
       
    return if current_user.email == email
    other = User.where(email: email).first
    if other
      raise "email belongs to other user error"
    end

    current_user.email = email
    current_user.verified_at = Time.now
    current_user.verification_code = nil
    current_user.bounce_count = 0
    current_user.last_bounce_at = nil
    current_user.save!
  end
end
