class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']
    unless @auth = Authorization.find_by_provider_and_uid(auth['provider'], auth['uid'])
      # Create a new user or add an auth to existing user, depending on
      # whether there is already a user signed in.
      user ||= User.create!(:real_name => auth['info']['name'])
      @auth = user.authorizations.create(:uid => auth['uid'], :provider => auth['provider'])
    end
    # Log the authorizing user in.
    self.current_user = @auth.user
    add_email auth['info']['email']
    
    session[:fb_token] = auth["credentials"]["token"] #save this for later
    cookies[:autosignin] = {
      :value => true,
      :expires => 1.year.from_now
    }

    flash[:notice] = "Welcome, #{current_user.real_name}."
    redirect_to session.delete(:jump_to) || "/"
  end

  def mobile_login
    fb_user = FbGraph2::User.new('me', :access_token => params[:fb_auth_token]).
      fetch(fields: [:name, :email])
    # This may error out, but would be caught in application controller

    session[:fb_token] = params[:fb_auth_token]
    auth = Authorization.find_by_provider_and_uid("facebook", fb_user.id)
    if !auth
      user = User.create!(:real_name => fb_user.name)
      auth = user.authorizations.create(uid: fb_user.id, provider: "facebook")
    end

    # Log the authorizing user in.
    self.current_user = auth.user
    add_email fb_user.email

    render :json => "Logged in!"
  end

  private

  def add_email(email)
    return if !email
       
    return if current_user.emails.find_by_email(email)
    current_user.emails.create :email => email, :auto => true, :primary => true
  end
end
