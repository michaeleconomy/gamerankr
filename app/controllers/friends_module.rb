module FriendsModule

  protected

  def refresh_friends_if_havent_yet
    if signed_in?
      if !session[:refreshed_friends] 
        refresh_friends
      end
    end
  end

  def refresh_friends
    if !current_user.facebook_user || !current_user.facebook_user.token
      logger.info "could not refresh friends - no fb token found"
      session[:refreshed_friends] = Time.now
      return
    end

    logger.info "refreshing friends for user: #{current_user.id}"
    existing_db_friend_ids = Set.new
    current_user.friends.each do |f|
      existing_db_friend_ids << f.friend_id
    end
    friend_ids_from_fb.each do |user_id|
      if existing_db_friend_ids.delete?(user_id)
        # already exists - do nothing
      else
        Friend.make current_user.id, user_id
      end
    end

    #now delete the leftover friends
    existing_db_friend_ids.each do |user_id|
      Friend.unmake current_user.id, user_id
    end

    Friend.connection.clear_query_cache

    session[:refreshed_friends] = Time.now
  end

  private
  
  def facebook_friends
    return @facebook_friend_ids if @facebook_friend_ids
    return [] unless signed_in?
    
    fb_user = FbGraph2::User.new('me', :access_token => current_user.facebook_user.token)
    @facebook_friend_ids = fb_user.friends
  end
  
  def friend_ids_from_fb
    return [] unless signed_in?
    friend_authorizations =
      Authorization.facebook.by_uid(facebook_friends.collect(&:identifier))
    friend_authorizations.collect(&:user_id)
  end
end