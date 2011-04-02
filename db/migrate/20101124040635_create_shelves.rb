class CreateShelves < ActiveRecord::Migration
  def self.up
    create_table :shelves do |t|
      t.integer :user_id, :null => false
      t.integer :game_shelves_count, :null => false, :default => 0
      t.string :name, :limit => 48, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :shelves
  end
end
