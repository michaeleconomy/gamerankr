class IndexPortsOnGameId < ActiveRecord::Migration[5.1]
  def change
    add_index :ports, :game_id
  end
end
