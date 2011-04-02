class CreateGameShelves < ActiveRecord::Migration
  def self.up
    create_table :game_shelves do |t|
      t.integer :game_id, :null => false
      t.integer :port_id, :null => false
      t.integer :shelf_id, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :game_shelves
  end
end
