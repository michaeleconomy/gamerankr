class BestPortId < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :best_port_id, :integer
  end
end
