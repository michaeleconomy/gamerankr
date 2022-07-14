class GameGenre < ActiveRecord::Base
  belongs_to :game
  belongs_to :genre, counter_cache: true
  
  validates_presence_of :game, :genre
  validates_uniqueness_of :game_id, :scope => :genre_id

  # TODO, enable this after i've got some basic genres added
  # after_destroy :delete_empty_genre
  
  private
  
  def delete_empty_genre
    if genre && genre.game_genres.count == 0
      genre.destroy
    end
    
    true
  end
  
end
