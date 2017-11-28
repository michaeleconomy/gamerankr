class FriendsController < ApplicationController
  before_action :require_sign_in
  def index
    @friends = User.where(id: friend_ids)
    @facebook_friends = friends_not_on_gr_ids
    @updates = Ranking.where(user_id: friend_ids).
      order("id desc").
      paginate(:page => params[:page])
  end
  
end
