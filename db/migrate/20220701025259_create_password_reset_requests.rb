class CreatePasswordResetRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :password_reset_requests do |t|
      t.integer :user_id, null: false
      t.string :code, null: false
      t.timestamps
    end
  end
end
