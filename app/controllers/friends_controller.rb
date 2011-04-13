class FriendsController < ApplicationController
  before_filter :require_sign_in
  def index
    @friends = User.find_all_by_id(friend_ids)
    @facebook_friends = friends_not_on_gr_ids
  end
  
end
