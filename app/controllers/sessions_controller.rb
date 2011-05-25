class SessionsController < ApplicationController
  before_filter :load_user, :only => [:fake_sign_in]
  
  def create
    auth = request.env['rack.auth']
    unless @auth = Authorization.find_by_provider_and_uid(auth['provider'], auth['uid'])
      # Create a new user or add an auth to existing user, depending on
      # whether there is already a user signed in.
      user ||= User.create!(:real_name => auth['user_info']['name'])
      @auth = user.authorizations.create(:uid => auth['uid'], :provider => auth['provider'])
    end
    # Log the authorizing user in.
    self.current_user = @auth.user
    if auth['extra'] &&
       auth['extra']['user_hash'] &&
       auth['extra']['user_hash']['email']
      email = auth['extra']['user_hash']['email']
      unless current_user.emails.find_by_email(email)
        current_user.emails.each(&:destroy)
        current_user.emails.create :email => email, :auto => true
      end
    end
    session[:omniauth] = auth

    flash[:notice] = "Welcome, #{current_user.real_name}."
    redirect_to session.delete(:jump_to) || "/"
  end
end
