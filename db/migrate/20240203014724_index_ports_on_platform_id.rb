class IndexPortsOnPlatformId < ActiveRecord::Migration[7.0]
  def change
    add_index :ports, :platform_id
  end
end
