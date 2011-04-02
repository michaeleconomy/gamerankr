class EditRankings < ActiveRecord::Migration
  def self.up
    remove_column :rankings, :resource_id, :resource_type
    add_column :rankings, :game_id, :integer, :null => false
    add_column :rankings, :port_id, :integer, :null => false
  end

  def self.down
  end
end
