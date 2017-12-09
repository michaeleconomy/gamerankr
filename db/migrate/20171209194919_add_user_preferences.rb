class AddUserPreferences < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :preferences, :string, :limit => 4000, :null => false, :default => ""
  end
end
