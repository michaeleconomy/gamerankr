class UpdatesController < ApplicationController
  before_action :require_sign_in
  def index

    if current_user.followings.empty?
    	@not_following_anyone = true
      return
    end
    @updates = current_user.updates.
      includes(:game, :shelves,
        {:user => :facebook_user, :port => [:platform, :additional_data]}).
      paginate(:page => params[:page])

    get_rankings(@updates)
  end
end
