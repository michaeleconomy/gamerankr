class DesignersController < ApplicationController
  before_filter :load_designer, :only => [:show]
  
  def index
    @designers = Designer.order(:name).paginate :page => params[:page]
  end
  
  def show
    @games = @designer.games.order(:title).paginate :page => params[:page]
    get_rankings
  end
end
