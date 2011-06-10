class CreateSeries < ActiveRecord::Migration
  def self.up
    create_table :series do |t|
      t.string :name, :null => false, :limit => 128
      t.string :description, :limit => 4000
      t.timestamps
    end
    
    add_index :series, :name, :unique => :true
  end

  def self.down
    drop_table :series
  end
end
