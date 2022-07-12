class DropEmails < ActiveRecord::Migration[7.0]
  def change
    drop_table :emails
  end
end
