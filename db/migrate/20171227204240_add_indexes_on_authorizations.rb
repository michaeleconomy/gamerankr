class AddIndexesOnAuthorizations < ActiveRecord::Migration[5.1]
  def change
    add_column :authorizations, :token, :string, :limit => 4000
    add_index :authorizations, [:token, :provider], :unique => true
    add_index :authorizations, :user_id
  end
end
