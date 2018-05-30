class GamesController < ApplicationController
  before_action :load_game, :only => [:show]
  before_action :require_admin, :only => [:show]
  
  def show
    @games = @game.simular_games.collect(&:game).compact
  end
end