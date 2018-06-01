class SimularController < ApplicationController
  before_action :require_sign_in
  before_action :require_admin, :only => [:index]
  
  def index
    @recommendations = @current_user.
      includes(:simular_game => [{:ports => :platform}, :publishers])
  end
end