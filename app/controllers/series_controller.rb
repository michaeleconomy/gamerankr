class SeriesController < ApplicationController
  before_action :load_series, :only => [:show,
    :edit, :update, :destroy]
  before_action :require_admin, :only => [:edit, :update, :destroy]
  
  def index
    @series = Series.order(:name).paginate :page => params[:page]
  end
  
  def show
    @games = @series.games.
      includes(:publishers, ports: [:platform, :additional_data]).
      paginate :page => params[:page]
    get_rankings
  end
  
  
  def edit
    @series.attributes = params[:series]
  end
  
  def update
    if @series.update(series_params)
      redirect_to :series
      return
    end
    render :action => 'edit'
  end
  
  def destroy
    @series.destroy
    flash[:notice] = "Series deleted"
    redirect_to "/"
  end
  
  private
  
  def series_params
    params.require(:series).permit(:title)
  end
end
