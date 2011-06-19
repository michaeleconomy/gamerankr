class AddPortDescription < ActiveRecord::Migration
  def self.up
    add_column :ports, :description, :string, :limit => 4000
  end

  def self.down
    remove_column :ports, :description
  end
end
