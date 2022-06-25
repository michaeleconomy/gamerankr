class PortsController < ApplicationController
  before_action :require_sign_in, :except => [:show, :cover]
  before_action :load_port,
    :only => [:show, :cover, :edit, :update, :destroy, :split]
  before_action :require_admin, :only => [:edit, :update, :destroy]
  
  def show
    redirect_to game_path(@port.game, :port_id => @port.id)
  end
  
  def cover
    
  end
  
  def new
    @port = Port.new
  end
  
  def create
    @port = Port.new(port_params)
    @port.source = "user #{current_user.id}"
    @port.game = Game.find_or_initialize_by(:title => @port.title)
    if @port.save
      redirect_to @port
      return
    end
    render :action => 'new'
  end
  
  def edit
    @port.attributes = params[:port] || {}
  end
  
  def update
    if @port.update(port_params)
      redirect_to :port
      return
    end
    render :action => 'edit'
  end
  
  def destroy
    @port.destroy
    flash[:notice] = "Port destroyed"
    redirect_to "/"
  end
  
  def split
    @port.split
    
    flash[:notice] = "Port split"
    redirect_to @port
  end
  
  private
  
  def port_params
    params.require(:port).
      permit(:title,
        :platform_id,
        :released_at,
        :released_at_accuracy,
        :upc,
        :ean,
        :manufacturer,
        :brand,
        :description)
  end
end
