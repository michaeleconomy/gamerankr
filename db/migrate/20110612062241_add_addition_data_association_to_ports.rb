class AddAdditionDataAssociationToPorts < ActiveRecord::Migration
  def self.up
    add_column :ports, :additional_data_type, :string, :limit => 64
    add_column :ports, :additional_data_id, :integer
    
    add_index :ports, [:additional_data_id, :additional_data_type], :unique => true
  end

  def self.down
    remove_column :ports, :additional_data_type, :additional_data_id
  end
end
