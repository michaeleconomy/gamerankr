class AddAFewMoreDataColumns < ActiveRecord::Migration
  def self.up
    add_column :ports, :binding, :string
  end

  def self.down
    remove_column :ports, :binding
  end
end
