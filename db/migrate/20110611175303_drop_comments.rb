class DropComments < ActiveRecord::Migration
  def self.up
    drop_table :comments
  end
  
  def self.down
    create_table :comments do |t|
      t.integer :user_id, :null => false
      t.integer :resource_id, :null => false
      t.string :resource_type, :null => false
      t.text :body, :null => false
      t.timestamps
    end
  end
end
