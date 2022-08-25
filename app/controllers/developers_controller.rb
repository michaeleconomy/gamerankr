class DevelopersController < ApplicationController
  before_action :load_developer, only: [:show]
  
  def index
    @developers = Developer.order(:name).
      paginate page: params[:page]
  end
  
  def show
    @games = add_game_sort(@developer.games.
      default_preload.
      paginate page: params[:page])
    get_rankings
  end
end
