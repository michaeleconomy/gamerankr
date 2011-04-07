class CreateAdmins < ActiveRecord::Migration
  def self.up
    create_table :admins do |t|
      t.integer :user_id, :null => false
      t.timestamps
    end
    
    add_index :admins, :user_id, :unique => true
  end

  def self.down
    drop_table :admins
  end
end
