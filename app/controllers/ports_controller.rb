class PortsController < ApplicationController
  before_filter :require_sign_in, :except => [:show, :cover]
  before_filter :load_port, :only => [:show, :cover]
  
  def show
    redirect_to @port.game
  end
  
  def cover
    
  end
end
