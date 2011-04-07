class GameGenresController < ApplicationController
  before_filter :load_game_genre, :only => [:destroy]
  before_filter :load_game, :only => [:game]
  before_filter :require_admin
  
  
  def game
    @port = @game.port
    @game_genres = @game.game_genres.includes(:genre).index_by(&:genre_id)
    @all_genres = Genre.all
  end
  
  def create
    @game_genre = GameGenre.new(params[:game_genre])
    
    respond_to do |format|
      if @game_genre.save
        format.html do
          flash[:notice] = "Genre added."
          redirect_to @game_genre.game
        end
        format.js do
          render :text => "Genre added."
        end
      else
        message = "Genre failed to add: " +
          @game_genre.errors.full_messages.to_sentence
        format.html do
          flash[:notice] = message
          redirect_to @game_genre.game
        end
        format.js do
          render :text => message, :status => 400
        end
      end
    end
  end
  
  def destroy
    @game_genre.destroy
    
    respond_to do |format|
      format.html do
        flash[:notice] = "Genre removed."
        redirect_to @game_genre.game
      end
      format.js do
        render :text => "Genre removed."
      end
    end
  end
end
