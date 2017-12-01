class CorrectEmailBounceCount < ActiveRecord::Migration[5.1]
  def change
    remove_column :emails, :bounce_count
    add_column :emails, :bounce_count, :integer, :default => 0, :null => false
  end
end
