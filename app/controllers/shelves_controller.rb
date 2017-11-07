class ShelvesController < ApplicationController
  include RankingsSorting
  
  before_action :load_shelf, :only => [:show]
  before_action :require_sign_in, :except => [:show]
  
  def show
    get_sort
    get_view
    @user = @shelf.user
    @rankings = @shelf.rankings.includes(:game, :port).paginate :page => params[:page]
    get_rankings
  end
end
