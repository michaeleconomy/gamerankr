class CreatePlatformAliases < ActiveRecord::Migration
  def self.up
    create_table :platform_aliases do |t|
      t.integer :platform_id, :null => false
      t.string :name, :null => false
      t.timestamps
    end
    add_index :platform_aliases, :platform_id
    add_index :platform_aliases, :name, :unique => true
  end

  def self.down
    drop_table :platform_aliases
  end
end
