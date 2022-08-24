class GenresController < ApplicationController
  before_action :load_genre, only: [:show, :edit, :update, :destroy]
  before_action :require_admin, only: [:edit, :update, :destroy]
  
  def index
    @genres = Genre.order('name').paginate(page: params[:page], per_page: 100)
  end
  
  def show
    @games = add_game_sort(@genre.
      games.
      default_preload.
      paginate(page: params[:page]))
  end
  
  def create
    @genre = Genre.new(params[:genre])
    
    respond_to do |format|
      if @genre.save
        format.html do
          flash[:notice] = "Genre created."
          redirect_to @genre
        end
        format.js do
          render plain: "Genre created."
        end
      else
        message = "Genre invalid: " +
          @genre.errors.full_messages.to_sentence
        format.html do
          flash[:notice] = message
          redirect_to genres_path
        end
        format.js do
          render plain: message, status: 400
        end
      end
    end
  end
  
  def edit
  end
  
  def update
    @genre.attributes = params[:genre]
    
    respond_to do |format|
      if @genre.save
        format.html do
          flash[:notice] = "Genre edited."
          redirect_to @genre
        end
        format.js do
          render plain: "Genre edited."
        end
      else
        message = "Failed to edit genre: " +
          @genre.errors.full_messages.to_sentence
        format.html do
          flash[:notice] = message
          redirect_to @genre
        end
        format.js do
          render plain: message, status: 400
        end
      end
    end
  end
  
  def destroy
    @genre.destroy
    
    respond_to do |format|
      format.html do
        flash[:notice] = "Genre deleted."
        redirect_to genres_path
      end
      format.all do
        render plain: "Genre deleted."
      end
    end
  end
end
