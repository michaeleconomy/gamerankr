class CreateGenres < ActiveRecord::Migration
  def self.up
    create_table :genres do |t|
      t.integer :game_genres_count, :default => 0, :null => false
      t.string :name, :limit => 100, :null => false
      t.text :description

      t.timestamps
    end
    
    add_index :genres, :name, :unique => true
    add_index :genres, :game_genres_count
  end

  def self.down
    drop_table :genres
  end
end
