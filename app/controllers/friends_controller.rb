class FriendsController < ApplicationController
  before_action :require_sign_in
  def index
    @friends = User.where(id: friend_ids).includes(:facebook_user)
    @facebook_friends = friends_not_on_gr_ids
    @updates = Ranking.where(user_id: friend_ids).
      includes(:game, :shelves, {:user => :facebook_user, :port => [:platform, :additional_data]}).
      order("id desc").
      paginate(:page => params[:page])

    get_rankings(@updates)
  end
  
end
