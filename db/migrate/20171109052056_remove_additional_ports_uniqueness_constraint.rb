class RemoveAdditionalPortsUniquenessConstraint < ActiveRecord::Migration[5.1]
  def up
    remove_index :ports, [:additional_data_id, :additional_data_type]
    add_index :ports, [:additional_data_id, :additional_data_type], :unique => false
  end
  def down
    remove_index :ports, [:additional_data_id, :additional_data_type]
    add_index :ports, [:additional_data_id, :additional_data_type], :unique => true
  end
end
