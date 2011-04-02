class CreateRankings < ActiveRecord::Migration
  def self.up
    create_table :rankings do |t|
      t.integer :user_id, :null => false
      t.integer :ranking, :null => false
      t.integer :resource_id, :null => false
      t.string :resource_type, :limit => 128, :null => false
      t.timestamps
    end
    add_index :rankings, [:user_id, :resource_id, :resource_type], :unique => true
    add_index :rankings, [:resource_id, :resource_type]
  end

  def self.down
    drop_table :rankings
  end
end
