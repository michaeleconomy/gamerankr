class CreateDeveloperGames < ActiveRecord::Migration
  def self.up
    create_table :developer_games do |t|
      t.integer :developer_id, :null => false
      t.integer :game_id, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :developer_games
  end
end
