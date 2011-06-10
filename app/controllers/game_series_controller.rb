class GameSeriesController < ApplicationController
  before_filter :load_game_series, :only => [:update, :destroy]
  before_filter :require_admin
  
  
  def create
    @game_series = GameSeries.new params[:game_series]
    if @game_series.save
      render :json => @game_series
      return
    end
    render :text => "Failed to create game_series: #{@game_series.errors.full_messages.join(", ")}",
      :status => 400
  end
  
  def update
    @game_series.attributes = params[:game_series]
    if @game_series.save
      render :json => @game_series
      return
    end
    render :text => "Failed to save: #{@game_series.errors.full_messages.join(", ")}",
      :status => 400
  end
  
  def destroy
    @game_series.destroy
    render :text => "Deleted"
  end
end
