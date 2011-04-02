class PlatformsController < ApplicationController
  before_filter :load_platform, :only => [:show]
  
  def index
    @platforms = Platform.where("name is not null").paginate :page => params[:page]
  end
  
  def show
    @ports = @platform.ports.paginate :page => params[:page]
    get_rankings
  end
end
