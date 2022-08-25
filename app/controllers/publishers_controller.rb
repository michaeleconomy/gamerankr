class PublishersController < ApplicationController
  before_action :load_publisher, only: [:show]
  
  def index
    @publishers = Publisher.order(:name).paginate page: params[:page]
  end
  
  def show
    @games = add_game_sort(@publisher.games.
      default_preload.
      paginate page: params[:page])
    get_rankings
  end
end
