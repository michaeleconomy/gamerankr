class CreateAndroidMarketplacePorts < ActiveRecord::Migration
  def self.up
    create_table :android_marketplace_ports do |t|
      t.string :am_id, :limit => 64, :null => false
      t.string :url, :limit => 256, :null => false
      t.string :image_url, :limit => 256
      t.integer :price
      t.string :description, :limit => 4000
      t.timestamps
    end
    
    add_index :android_marketplace_ports, :am_id, :unique => true
  end

  def self.down
    drop_table :android_marketplace_ports
  end
end
