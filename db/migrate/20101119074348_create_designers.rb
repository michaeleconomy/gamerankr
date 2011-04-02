class CreateDesigners < ActiveRecord::Migration
  def self.up
    create_table :designers do |t|
      t.string :name
      t.integer :designer_games_count, :default => 0, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :designers
  end
end
