class CreatePublisherGames < ActiveRecord::Migration
  def self.up
    create_table :publisher_games do |t|
      t.integer :publisher_id, :null => false
      t.integer :game_id, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :publisher_games
  end
end
