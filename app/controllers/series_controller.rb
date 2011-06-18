class SeriesController < ApplicationController
  before_filter :load_series, :only => [:show, :search_and_add,
    :edit, :update, :destroy]
  before_filter :require_admin, :only => [:edit, :update, :destroy,
    :search_and_add]
  
  def index
    @series = Series.paginate :page => params[:page], :order => 'title'
  end
  
  def show
    @games = @series.games.paginate :page => params[:page]
  end
  
  def search_and_add
    @query = params[:query]
    unless @query.blank?
      begin
        @results = Search::AmazonSearch.for(@query, :page => params[:page])
      rescue Amazon::RequestError => e
        @error = e
      end
    end
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
