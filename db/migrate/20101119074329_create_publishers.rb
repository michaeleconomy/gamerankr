class CreatePublishers < ActiveRecord::Migration
  def self.up
    create_table :publishers do |t|
      t.string :name
      t.integer :publisher_games_count, :default => 0, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :publishers
  end
end
