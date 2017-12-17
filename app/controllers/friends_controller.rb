class FriendsController < ApplicationController
  before_action :require_sign_in
  def index
    friend_ids = current_user.friend_user_ids
    @friends = User.where(id: friend_ids).includes(:facebook_user)
    @updates = current_user.updates.
      includes(:game, :shelves,
        {:user => :facebook_user, :port => [:platform, :additional_data]}).
      paginate(:page => params[:page])

    get_rankings(@updates)
  end
  
end
