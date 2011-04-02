class CreateDevelopers < ActiveRecord::Migration
  def self.up
    create_table :developers do |t|
      t.string :name
      t.integer :developer_games_count, :default => 0, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :developers
  end
end
