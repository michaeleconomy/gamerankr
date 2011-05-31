class CreateManufacturers < ActiveRecord::Migration
  def self.up
    create_table :manufacturers do |t|
      t.string :name, :limit => 128, :null => false
      t.string :description, :limit => 4000
      t.integer :platforms_count, :default => 0, :null => false
      t.timestamps
    end
    add_index :manufacturers, :name, :unique => true
    add_column :platforms, :manufacturer_id, :integer
    add_index :platforms, :manufacturer_id
  end

  def self.down
    drop_table :manufacturers
    add_column :platforms, :manufacturer_id
  end
end
