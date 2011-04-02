class DevelopersController < ApplicationController
  before_filter :load_developer, :only => [:show]
  
  def show
    @ports = @developer.ports.paginate :page => params[:page]
    get_rankings
  end
end
