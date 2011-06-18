class CreateItunesPorts < ActiveRecord::Migration
  def self.up
    create_table :itunes_ports do |t|
      t.integer :track_id, :null => false
      t.integer :price
      t.string :url, :limit => 256, :null => false
      t.string :small_image_url, :limit => 256
      t.string :medium_image_url, :limit => 256
      t.string :large_image_url, :limit => 256
      t.string :version, :limit => 16
      t.string :description, :limit => 4000
      t.timestamps
    end
    
    add_index :itunes_ports, :track_id, :unique => true
  end

  def self.down
    drop_table :itunes_ports
  end
end
