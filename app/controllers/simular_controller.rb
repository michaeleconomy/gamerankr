class SimularController < ApplicationController
  before_action :load_game, :only => [:show]
  before_action :require_admin, :only => [:show]
  
  def show
    @simular_games = SimularGame.get_for_game(@game).
      includes(:simular_game => [{:ports => [:platform, :additional_data]}, :publishers])
    get_rankings(@simular_games.collect(&:simular_game))
  end
end