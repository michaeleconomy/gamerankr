class CreateDesignerGames < ActiveRecord::Migration
  def self.up
    create_table :designer_games do |t|
      t.integer :designer_id, :null => false
      t.integer :game_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :designer_games
  end
end
