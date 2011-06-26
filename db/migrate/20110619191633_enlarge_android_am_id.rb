class EnlargeAndroidAmId < ActiveRecord::Migration
  def self.up
    change_column :android_marketplace_ports, :am_id, :string, :limit => 128, :null => false
  end

  def self.down
    change_column :android_marketplace_ports, :am_id, :string, :limit => 64, :null => false
  end
end
