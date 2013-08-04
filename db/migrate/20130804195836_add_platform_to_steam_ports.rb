class AddPlatformToSteamPorts < ActiveRecord::Migration
  def change
    add_column :steam_ports, :platform, :string, :limit => 32, :null => false
    remove_index :steam_ports, :column => [:steam_id], :unique => true
    add_index :steam_ports, [:steam_id, :platform], :unique => true
  end
end
