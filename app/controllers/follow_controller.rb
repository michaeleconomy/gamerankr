class FollowController < ApplicationController
  before_action :require_sign_in, :except => [:followers, :following]
  before_action :load_user, :only => [:follow, :unfollow, :followers, :following]

  def follow
    if current_user.following_count >= Follow.MAX_FOLLOWINGS
      respond_to do |format|
        format.js do
          render :json => "You cannot follow more than #{Follow.MAX_FOLLOWINGS} people.".to_json, :status => 400
        end
      end
      return
    end
    @user.followers.create(follower_id: current_user.id)

    respond_to do |format|
      format.js do
        render :json => "following"
      end
    end
  end

  def unfollow
    following = @user.followers.where(follower_id: current_user.id).first
    if !following
      respond_to do |format|
        format.js do
          render :json => "following not found".to_json, :status => 404
        end
      end
      return
    end

    following.destroy

    respond_to do |format|
      format.js do
        render :json => "unfollowed".to_json
      end
    end
  end

  def followers
    @followers =
      @user.followers.
      includes(:follower).
      order(Arel.sql("id desc")).
      paginate :page => params[:page]
  end

  def following
    @followings =
      @user.followings.
      includes(:following).
      order(Arel.sql("id desc")).
      paginate :page => params[:page]
  end
end