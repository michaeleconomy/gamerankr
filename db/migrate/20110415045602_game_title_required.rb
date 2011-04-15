class GameTitleRequired < ActiveRecord::Migration
  def self.up
    change_column :games, :title, :string, :null => false
  end

  def self.down
    change_column :games, :title, :string, :null => true
  end
end
