class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user, :signed_in?, :is_admin?,
    :signed_out?, :friends_not_on_gr_ids, :current_user_is_user?
  
  before_filter :log_stuff, :auto_sign_in
  
  protected
  
  def facebook_friends
    return @facebook_friend_ids if @facebook_friend_ids
    return [] unless signed_in?
    
    fb_user = FbGraph::User.new('me', :access_token => session[:omniauth]["credentials"]["token"])
    @facebook_friend_ids = fb_user.friends
  end
  
  def friend_ids
    return @friend_ids if @friend_ids
    return [] unless signed_in?
    friend_authorizations = Authorization.facebook.by_uid(facebook_friends.collect(&:identifier))
    facebook_gr_friend_ids = friend_authorizations.index_by(&:uid)
    @friends_not_on_gr_ids = facebook_friends.delete_if{|f| facebook_gr_friend_ids[f.identifier]}
    @friend_ids = friend_authorizations.collect(&:user_id)
  end
  
  def friends_not_on_gr_ids
    return @friends_not_on_gr_ids if @friends_not_on_gr_ids
    friend_ids
    @friends_not_on_gr_ids
  end
    

  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end

  def signed_out?
    !current_user
  end

  def signed_in?
    !signed_out?
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
    if signed_out? || ports.empty?
      return @user_rankings = {}
    end
    ids = 
      if ports.first.is_a?(Game)
        ports.collect(&:id)
      else
        ports.collect(&:game_id)
      end.uniq
    @user_rankings =
      current_user.rankings.includes(:ranking_shelves => :shelf).find_all_by_game_id(ids).index_by(&:game_id)
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
          render :text => "sign in required", :status => 401
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
end
