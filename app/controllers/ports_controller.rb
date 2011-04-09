class PortsController < ApplicationController
  before_filter :require_sign_in, :except => [:show, :cover]
  before_filter :load_port, :only => [:show, :cover, :edit, :update, :destroy]
  
  def show
    redirect_to @port.game
  end
  
  def cover
    
  end
  
  def new
    @port = Port.new(params[:port])  
  end
  
  def create
    @port = Port.new(params[:port])
    
    if @port.save
      redirect_to @port
    end
    render :action => 'new'
  end
  
  def edit
    @port.attributes = params[:port]
  end
  
  def update
    if @port.update_attributes(params[:port])
      redirect_to :port
  end
  
  
  
  def destroy
    @port.destroy
    flash[:notice] = "Port destroyed"
    redirect_to "/"
  end
end
