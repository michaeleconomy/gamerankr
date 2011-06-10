class CreateGameSeries < ActiveRecord::Migration
  def self.up
    create_table :game_series do |t|
      t.integer :game_id, :null => false
      t.integer :series_id, :null => false
      
      t.integer :position, :null => false
      t.timestamps
    end
    
    add_index :game_series, [:game_id, :series_id], :unique => :true
    add_index :game_series, :series_id
  end

  def self.down
    drop_table :game_series
  end
end
