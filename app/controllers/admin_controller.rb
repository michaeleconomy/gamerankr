class AdminController < ApplicationController
  before_filter :require_admin
  
  def search_and_edit
    @query = params[:query].to_s.downcase
    if @query.present?
      @games = Game.where("lower(title) like ?", "%#{@query}%")
    end
  end
  
  def multi_edit
    games = Game.where(:id => params[:game_ids])
    if games.empty?
      render :text => "'No games selected!'", :status => 400
      return
    end
    case params[:commit]
    when "add genre"
      multi_add_genres(games, params[:genre_name])
    when "add series"
      multi_add_series(games, params[:series_name])
    when "merge games"
      merge_games(games)
    when "delete"
      delete_games(games)
    else
      render :text => '"unknown action"', :status => 400
    end
  end
  
  private
  
  def multi_add_genres(games, genre_name)
    genre = Genre.find_or_create_by(:name => genre_name)
    games.each do |game|
      game.game_genres.create(:genre => genre)
    end
    render :text => {:genre => genre_name}.to_json
  end
  
  def multi_add_series(games, series_name)
    series = Series.find_or_create_by(:name => series_name)
    games.each do |game|
      game.game_series.create(:series => series)
    end
    render :text => {:series => series_name}.to_json
  end
  
  def merge_games(games)
    first = games.shift
    if games.empty?
      render :text => "'must choose multiple games to merge!'"
      return
    end
    games.each do |game|
      first.merge(game)
    end
    render :text => "'#{games.size} games merged'"
  end
  
  def delete_games(games)
    games.each(&:destroy)
    render :text => "'#{games.size} games deleted'"
  end
end