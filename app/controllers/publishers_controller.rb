class PublishersController < ApplicationController
  before_filter :load_publisher, :only => [:show]
  
  def index
    @publishers = Publisher.paginate :page => params[:page]
  end
  
  def show
    @ports = @publisher.ports.paginate :page => params[:page]
    get_rankings
  end
end
