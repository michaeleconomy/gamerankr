class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.integer :resource_id, :null => false
      t.string :resource_type, :null => false, :limit => 256
      t.integer :user_id, :null => false, :index => true
      t.string :comment, :limit => 4000, :null => false
      t.timestamps
    end
    add_index :comments, [:resource_id, :resource_type]
  end
end
