class ApplicationController < ActionController::Base
  include FriendsModule
  protect_from_forgery
  helper_method :current_user, :signed_in?, :is_admin?,
    :signed_out?, :current_user_is_user?
  
  before_action :log_stuff, :auto_sign_in, :refresh_friends_if_havent_yet
  rescue_from FbGraph2::Exception, :with => :invalid_facebook_session  
  
  protected

  def current_user
    session[:user_id] && @current_user ||= User.find_by_id(session[:user_id])
  end

  def signed_out?
    !current_user
  end

  def signed_in?
    !signed_out?
  end
  
  def sign_out
    session.clear
  end
  
  def is_admin?
    signed_in? && current_user.admin
  end

  def current_user=(user)
    @current_user = user
    session[:user_id] = user.id
  end
  
  def current_user_is_user?
    signed_in? && @user && @user.id == current_user.id
  end
  
  def get_rankings(ports = nil)
    ports ||= @ports
    ports ||= @games
    ports ||= @rankings
    if signed_out? || !ports || ports.empty?
      return @user_rankings = {}
    end
    ids = 
      if ports.first.is_a?(Game)
        ports.collect(&:id)
      else
        ports.collect(&:game_id)
      end.uniq
    @user_rankings =
      current_user.rankings.includes(:ranking_shelves => :shelf).where(:game_id => ids).index_by(&:game_id)
  end
  
  private
  
  def log_stuff
    logger.info "ip:#{request.ip} request_format:#{request.format} " +
      "#{signed_in? ? "current_user_id #{current_user.id}" : "signed out"} " +
      "url #{request.url} useragent #{request.user_agent}"
    
    true
  end
  
  def auto_sign_in
    if signed_out? && cookies[:autosignin] && request.get? &&
       (params[:format].nil? || params[:format] == "html") &&
       (!session[:auto_sign_in_attempted])
      logger.info "attempting auto-sign-in"
      session[:jump_to] = request.url
      session[:auto_sign_in_attempted] = true
      redirect_to '/auth/facebook'
      return false
    end
    
    true
  end
  
  %w(Comment Designer Developer Game GameGenre GameSeries Genre
    Manufacturer Platform Port 
    ProfileQuestion Publisher
    Ranking RankingShelf Series Shelf User).each do |klass_name|
    klass = klass_name.constantize
    define_method "load_#{klass_name.underscore}" do
      item = klass.find_by_id(params[:id])
      unless item
        respond_to do |format|
          format.html do
            flash[:error] = "#{klass_name.humanize} not found."
            redirect_to "/"
          end
          format.js do
            render :status => 404, :text => "not found"
          end
        end
        return false
      end
      instance_variable_set "@" + klass_name.underscore, item
    end
  end
  
  def require_sign_in
    unless signed_in?
      respond_to do |format|
        format.html do
          session[:jump_to] = request.url
          redirect_to '/auth/facebook'
        end
        format.js do
          render :plain => "sign in required", :status => 401
        end
      end
      return false
    end
    
    true
  end
  
  def require_admin
    unless is_admin?
      respond_to do |format|
        format.html do
          flash[:notice] = "admins only!"
          redirect_to '/'
        end
      end
      return false
    end
    
    true
  end
  
  def invalid_facebook_session
    logger.info "facebook session error - logging out"
    sign_out

    respond_to do |format|
      format.html do
        flash[:notice] = "Facebook session error"
        redirect_to "/"
      end
      format.json do
        render :json => "Facebook session error"
      end
    end
  end
  

  def mobile_sign_on
    token = request.headers["api-token"]

    if !token
      return
    end

    a = Authorization.where(token: token, provider: "gamerankr-ios").first
    if !a
      logger.info "token not found in db"
      render :json => "token could not be found", :status => 401
      return
    end

    if signed_in?
      if a.user_id != current_user.id
          logger.error "using a different user's token?!"
          render :json => "token mismatch", :status => 401
          return
      end
      logger.info "token matches"
      #already signed in!
      return
    end

    if !a.user
      logger.error "token matched an authorization, but had no user!"
      render :json => "token could not be found", :status => 401
      return
    end
    logger.info "signing in via api-token"
    
    self.current_user = a.user
  end

end