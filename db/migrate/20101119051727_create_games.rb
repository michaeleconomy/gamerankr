class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.string :title
      t.integer :series_id
      t.text :description
      t.integer :rankings_count, :default => 0, :null => false
      t.string :rating
      t.string :source
      t.timestamps
    end
  end

  def self.down
    drop_table :games
  end
end
