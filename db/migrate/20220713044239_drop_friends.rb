class DropFriends < ActiveRecord::Migration[7.0]
  def change
    drop_table :friends
  end
end
