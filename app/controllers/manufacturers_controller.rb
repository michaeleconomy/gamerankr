class ManufacturersController < ApplicationController
  before_filter :load_manufacturer, :only => [:show, :edit, :update, :destroy]
  before_filter :require_admin, :only => [:edit, :update, :destroy]
  
  def index
    @manufacturers = Manufacturer.order('name').paginate :page => params[:page],
      :per_page => 100
  end
  
  def show
    @platforms = @manufacturer.platforms.order("released_at, id").paginate :page => params[:page]
  end
  
  def edit
    
  end
  
  def update
    if @manufacturer.update_attributes(params[:manufacturer])
      flash[:notice] = "Updated"
      redirect_to @manufacturer
      return
    end
    render :action => "edit"
  end
  
  def destroy
    @manufacturer.destroy
    redirect_to manufacturers_path
  end
  
end
