class AddLocationToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :location, :string, :limit => 4000
  end

  def self.down
    remove_column :users, :location
  end
end
