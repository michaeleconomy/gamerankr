class ChangeGameShelves < ActiveRecord::Migration
  def self.up
    rename_table :game_shelves, :ranking_shelves
    rename_column :ranking_shelves, :port_id, :ranking_id
    remove_column :ranking_shelves, :game_id
    
    rename_column :shelves, :game_shelves_count, :ranking_shelves_count
  end

  def self.down
  end
end
