class SeriesController < ApplicationController
  before_filter :load_series, :only => [:show, :edit, :update, :destroy]
  before_filter :require_admin, :only => [:edit, :update, :destroy]
  
  def index
    @series = Series.paginate :page => params[:page], :order => 'title'
  end
  
  def show
    @games = @series.games.paginate :page => params[:page]
  end
  
  def edit
    @series.attributes = params[:series]
  end
  
  def update
    if @series.update_attributes(params[:series])
      redirect_to :series
      return
    end
    render :action => 'edit'
  end
  
  def destroy
    @series.destroy
    flash[:notice] = "Series destroyed"
    redirect_to "/"
  end
end
