class SimularController < ApplicationController
  before_action :require_sign_in
  before_action :require_admin, :only => [:index]
  
  def index
    @simular_games = SimularGame.get_for_game(@game).
      includes(:simular_game => [{:ports => :platform}, :publishers])
  end
end