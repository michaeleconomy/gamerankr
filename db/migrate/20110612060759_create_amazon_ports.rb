class CreateAmazonPorts < ActiveRecord::Migration
  def self.up
    create_table :amazon_ports do |t|
      t.string :asin, :limit => 24, :null => false
      t.integer :price
      t.string :url, :limit => 256, :null => false
      t.string :image_url, :limit => 256
      t.string :description
      t.timestamps
    end
    add_index :amazon_ports, :asin, :unique => true
  end

  def self.down
    drop_table :amazon_ports
  end
end
