class GameGenresController < ApplicationController
  before_action :load_game_genre, :only => [:destroy]
  before_action :load_game, :only => [:game]
  before_action :require_admin
  
  
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
          render plain: "Genre added."
        end
      else
        message = "Genre failed to add: " +
          @game_genre.errors.full_messages.to_sentence
        format.html do
          flash[:notice] = message
          redirect_to @game_genre.game
        end
        format.js do
          render plain: message, status: 400
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
        render plain: "Genre removed."
      end
    end
  end
end
