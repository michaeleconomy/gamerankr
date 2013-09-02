class DevelopersController < ApplicationController
  before_filter :load_developer, :only => [:show]
  
  def index
    @developers = Developer.order(:name).paginate :page => params[:page]
  end
  
  def show
    @ports = @developer.ports.order(:title).paginate :page => params[:page]
    get_rankings
  end
end
