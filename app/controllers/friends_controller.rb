class FriendsController < ApplicationController
  before_action :require_sign_in
  def index
    friend_ids = current_user.friend_user_ids
    @friends = User.where(id: friend_ids).includes(:facebook_user)
    @updates = Ranking.where(user_id: friend_ids).
      includes(:game, :shelves,
        {:user => :facebook_user, :port => [:platform, :additional_data]}).
      order("id desc").
      paginate(:page => params[:page])

    get_rankings(@updates)
  end
  
end
