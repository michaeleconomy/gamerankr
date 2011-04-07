class CreateGameGenres < ActiveRecord::Migration
  def self.up
    create_table :game_genres do |t|
      t.integer :game_id, :null => false
      t.integer :genre_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :game_genres
  end
end
