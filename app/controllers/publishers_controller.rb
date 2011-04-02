class PublishersController < ApplicationController
  before_filter :load_publisher, :only => [:show]
  
  def show
    @ports = @publisher.ports.paginate :page => params[:page]
    get_rankings
  end
end
