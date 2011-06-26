class ExpandAmazonDescription < ActiveRecord::Migration
  def self.up
    change_column :amazon_ports, :description, :string, :limit => 4000
  end

  def self.down
    change_column :amazon_ports, :description, :string, :limit => 255
  end
end
