class IndexGameGenres < ActiveRecord::Migration[7.0]
  def change
    add_index :game_genres, [:game_id, :genre_id], unique: true
    add_index :game_genres, :genre_id
  end
end
