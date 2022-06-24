class FollowController < ApplicationController
  before_action :require_sign_in, :except => [:followers, :following]
  before_action :load_user, :only => [:follow, :followers, :following]

  def follow
  end
end