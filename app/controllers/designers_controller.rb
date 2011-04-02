class DesignersController < ApplicationController
  before_filter :load_designer, :only => [:show]
  
  def show
    @games = @designer.games.paginate :page => params[:page]
    get_rankings
  end
end
