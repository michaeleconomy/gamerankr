class DesignersController < ApplicationController
  before_filter :load_designer, :only => [:show]
  
  def index
    @designers = Designer.paginate :page => params[:page], :order => 'name'
  end
  
  def show
    @games = @designer.games.paginate :page => params[:page]
    get_rankings
  end
end
