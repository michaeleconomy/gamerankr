class AddMissingIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :follows, [:following_id, :follower_id], unique: true
    add_index :follows, :follower_id

    add_index :password_reset_requests, :user_id, unique: true

    add_index :authorizations, [:uid, :provider], unique: true
  end
end
