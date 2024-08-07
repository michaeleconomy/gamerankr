class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user, :signed_in?, :admin?,
    :signed_out?, :current_user_is_user?
  
  before_action :log_stuff, :auto_sign_in, :validate_page_param

  class DeletedUserException < Exception
  end

  rescue_from DeletedUserException, with: :rescue_delete_user_exception 
  rescue_from RangeError, with: :invalid_page_number 

  protected

  def current_user
    return nil if !session[:user_id]

    return @current_user if @current_user
    @current_user = User.find_by_id(session[:user_id])

    if !@current_user
      raise DeletedUserException
    end
    @current_user
  end

  def signed_out?
    !current_user
  end

  def signed_in?
    !signed_out?
  end
  
  def do_sign_user_out
    if cookies.signed[:lg]
      begin
        if current_user
          current_user.web_authorizations.where(uid: cookies.signed[:lg]).delete_all
        end
      rescue DeletedUserException
      end
      cookies.delete :lg
    end
    session[:user_id] = nil
  end
  
  def admin?
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
    @user_rankings = current_user.
      rankings.
      includes(ranking_shelves: :shelf).
      where(game_id: ids).
      index_by(&:game_id)
  end

  def get_followings(users = nil)
    users ||= @users
    if signed_out? || !users || users.empty?
      return @user_followings = {}
    end
    if !users.first.is_a?(User)
      raise "invalid type"
    end
    ids = users.map(&:id).uniq
    @user_followings = current_user.
      followings.
      where(following_id: ids).
      index_by(&:following_id)
  end



  def add_port_sort(ports)
    add_sort(ports, port_sorts, false)
  end

  def add_game_sort(ports)
    add_sort(ports, game_sorts, false)
  end

  def add_ranking_sort(rankings)
    add_sort(rankings, ranking_sorts, false)
  end


  def add_my_games_sort(rankings, desc)
    add_sort(rankings, my_games_sorts, desc)
  end
  
  private


  def add_sort(ports, sorts, desc)
    @sorts = sorts
    sort = @sorts.find{|s| s[0] == params[:sort]} || @sorts[0]
    @sort_by = sort[0]
    if sort[2]
      ports = ports.joins(sort[2])
    end
    sort_order = sort[1]
    if desc
      sort_order += " desc"
    end
    ports.order(sort_order)
  end

  def ranking_sorts
    [
      ["newest", "created_at desc"],
      ["oldest", "created_at"],
      ["popular", "games.rankings_count desc", :game],
      ["unpopular", "games.rankings_count", :game],
      ["ranking", "rankings", :game],
      ["alphabetical", "lower(games.title)", :game],
      ["release date", "games.initially_released_at", :game],
    ]
  end

  def my_games_sorts
    [
      ["Title", "lower(ports.title)", :port],
      ["Platform", "platforms.name", port: :platform],
      ["Date Added", "rankings.created_at"],
      ["Times Added", "games.rankings_count", :game],
      ["My Shelves", "rankings.id", :game],
      ["My Rating", "rankings.ranking"],
      ["My Review", "length(review)"],
    ]
  end

  def port_sorts
    [
      ["popular", "rankings_count desc"],
      ["alphabetical", "lower(title)"],
      ["release date", "games.initially_released_at", :game],
    ]
  end

  def game_sorts
    [
      ["popular", "rankings_count desc"],
      ["alphabetical", "lower(title)"],
      ["release date", "initially_released_at"],
    ]
  end

  
  def log_stuff
    logger.info "ip:#{request.ip} request_format:#{request.format} " +
      "#{signed_in? ? "current_user_id #{current_user.id}" : "signed out"} " +
      "url #{request.url} useragent #{request.user_agent}"
    
    true
  end

  def auto_sign_in
    if signed_out? && cookies.signed[:lg]
      authorization = Authorization.where(uid: cookies.signed[:lg], provider: 'web').first
      if authorization && authorization.user
        self.current_user = authorization.user
        cookies.signed.permanent[:lg] = cookies.signed[:lg]
        logger.info "Signed user in via web cookie: #{current_user.id}"
      else
        logger.info "Invalid web cookie, removing"
        cookies.delete :lg
      end
    end
    
    true
  end
  
  %w(Comment Designer Developer Franchise
    Game GameGenre GameSeries Genre
    Manufacturer Platform Port 
    ProfileQuestion Publisher
    Ranking RankingShelf Series Shelf SpamFilter).each do |klass_name|
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
            render status: 404, text: "not found"
          end
        end
        return false
      end
      instance_variable_set "@" + klass_name.underscore, item
    end
  end


  def load_user
    @user = User.where(id: params[:id]).where("verified_at is not null").first
    unless @user
      respond_to do |format|
        format.html do
          flash[:error] = "User not found."
          redirect_to "/"
        end
        format.js do
          render status: 404, text: "not found"
        end
      end
      return false
    end
    
    true
  end
  
  def require_sign_in
    unless signed_in?
      respond_to do |format|
        format.html do
          session[:jump_to] = request.url
          flash[:notice] = "You must be signed in to perform that action"
          redirect_to create_account_path
        end
        format.js do
          render plain: "sign in required", status: 401
        end
      end
      return false
    end
    
    true
  end


  def require_signed_out
    if signed_in?
      respond_to do |format|
        format.html do
          flash[:notice] = "You are already signed in"
          redirect_to "/"
        end
        format.js do
          render plain: "already signed in", status: 400
        end
      end
      return false
    end
    
    true
  end
  
  def require_admin
    unless admin?
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

  def validate_page_param
    if params[:page] != nil
      begin
        Integer(params[:page])
      rescue ArgumentError
        respond_to do |format|
          format.html do
            render plain: "Invalid page", status: 400
          end
          format.json do
            render json: "Invalid page", status: 400
          end
        end
        return false
      end
    end

    true
  end
  

  def rescue_delete_user_exception
    logger.info "deleted user exception - logging out"
    do_sign_user_out
    respond_to do |format|
      format.html do
        flash[:notice] = "Authentication error"
        redirect_to "/"
      end
      format.json do
        render json: "Authentication error", status: 401
      end
    end
  end


  def invalid_page_number
    respond_to do |format|
      format.html do
        render plain: "Invalid Page Number", status: 404
      end
      format.json do
        render json: "Invalid Page Number", status: 404
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
      render json: "token could not be found", status: 401
      return
    end

    if signed_in?
      if a.user_id != current_user.id
          logger.error "using a different user's token?!"
          render json:"token mismatch", status: 401
          return
      end
      logger.info "token matches"
      #already signed in!
      return
    end

    if !a.user
      logger.error "token matched an authorization, but had no user!"
      render json: "token could not be found", status: 401
      return
    end
    logger.info "signing in via api-token"
    
    self.current_user = a.user
  end

end