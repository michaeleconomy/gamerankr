class FranchisesController < ApplicationController
  before_action :load_franchise, only: [:show]
  # before_action :require_admin, :only => [:edit, :update, :destroy]
  
  def show
    @games = add_game_sort(@franchise.games.
      default_preload.
      paginate page: params[:page])
    get_rankings
  end
end
