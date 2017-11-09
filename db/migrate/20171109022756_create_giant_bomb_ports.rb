class CreateGiantBombPorts < ActiveRecord::Migration[5.1]
  def change
    create_table :giant_bomb_ports do |t|

      t.string :giant_bomb_id, :limit => 24, :null => false
      t.string :url, :limit => 256, :null => false
      t.string :image_id, :limit => 256
      t.string :description
      t.timestamps
    end
    add_index :giant_bomb_ports, :giant_bomb_id, :unique => true
  end
end
