class CreatePorts < ActiveRecord::Migration
  def self.up
    create_table :ports do |t|
      t.integer :game_id, :null => false
      t.integer :platform_id
      t.datetime :released_at
      t.string :source
      t.string :asin
      t.timestamps
    end
  end

  def self.down
    drop_table :ports
  end
end
