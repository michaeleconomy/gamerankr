class AdminController < ApplicationController
  before_action :require_admin

  def amazon_ports
    @ports = AmazonPort.includes(:port => :game).collect(&:port)
  end

  def search_and_edit
    @query = params[:query].to_s.downcase
    if @query.present?
      @games = Game.where("unaccent(lower(title)) like unaccent(lower(?))", "%#{@query}%").
        order("rankings_count desc, id desc").
        includes(:ports)
    end
  end
  
  def multi_edit
    games = Game.where(:id => params[:game_ids]).to_a
    if games.empty?
      render :plain => "'No games selected!'", :status => 400
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
      render :plain => '"unknown action"', :status => 400
    end
  end
  
  private
  
  def multi_add_genres(games, genre_name)
    genre = Genre.find_or_create_by(:name => genre_name)
    games.each do |game|
      game.game_genres.create(:genre => genre)
    end
    render :plain => {:genre => genre_name}.to_json
  end
  
  def multi_add_series(games, series_name)
    series = Series.find_or_create_by(:name => series_name)
    games.each do |game|
      game.game_series.create(:series => series)
    end
    render :plain => {:series => series_name}.to_json
  end
  
  def merge_games(games)
    if games.size < 2
      render :plain => "'must choose multiple games to merge!'"
      return
    end
    Tasks::Merger.merge_games(games)
    render :plain => "'#{games.size} games merged'"
  end
  
  def delete_games(games)
    games.each(&:destroy)
    render :plain => "'#{games.size} games deleted'"
  end
end