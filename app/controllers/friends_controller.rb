class FriendsController < ApplicationController
  before_action :require_sign_in
  def index
    if session[:missing_friends_permission]
      @rerequest_permissions = true
      return
    end

    friend_ids = current_user.friend_user_ids
    if friend_ids.empty?
      @friends = []
      return
    end
    @friends = User.where(id: friend_ids).includes(:facebook_user)
    @updates = current_user.updates.
      includes(:game, :shelves,
        {:user => :facebook_user, :port => [:platform, :additional_data]}).
      paginate(:page => params[:page])

    get_rankings(@updates)
  end
  
end
