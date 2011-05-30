class DevelopersController < ApplicationController
  before_filter :load_developer, :only => [:show]
  
  def index
    @developers = Developer.paginate :page => params[:page]
  end
  
  def show
    @ports = @developer.ports.paginate :page => params[:page]
    get_rankings
  end
end
