class CreateSteamPorts < ActiveRecord::Migration
  def change
    create_table :steam_ports do |t|
      t.string :steam_id, :limit => 64, :null => false
      t.integer :price
      t.string :description, :limit => 4000
      t.timestamps
    end

    add_index :steam_ports, :steam_id, :unique => true
  end
end
