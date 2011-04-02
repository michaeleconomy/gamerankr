class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :handle, :limit => 20
      t.string :real_name
      t.text :about
      t.integer :comments_count, :default => 0, :null => false
      t.integer :rankings_count, :default => 0, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
