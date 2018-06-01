class RecommendationsController < ApplicationController
  before_action :require_sign_in
  before_action :require_admin, :only => [:index]
  
  def index
    @recommendations = @current_user.recommendations.
      includes(:game => [{:ports => [:platform, :additional_data]}, :publishers]).
      order("score desc").
      paginate :page => params[:page]

    get_rankings(@recommendations.collect(&:game))
  end
end