class AddPortIds < ActiveRecord::Migration
  def self.up
    add_column :publisher_games, :port_id, :integer, :null => false
  end

  def self.down
  end
end
