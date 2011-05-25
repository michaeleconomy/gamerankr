class CreateEmails < ActiveRecord::Migration
  def self.up
    create_table :emails do |t|
      t.integer :user_id, :null => false
      t.string :email, :limit => 128, :null => false
      t.boolean :auto, :default => false, :null => false
      t.datetime :last_bounce_at
      t.datetime :bounce_count
      t.datetime :verified_at
      t.timestamps
    end
    add_index :emails, :user_id
    add_index :emails, :email, :unique => true
  end

  def self.down
    drop_table :emails
  end
end
