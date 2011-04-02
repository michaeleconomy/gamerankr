class AddGameInitiallyReleasedAt < ActiveRecord::Migration
  def self.up
    add_column :games, :initially_released_at_accuracy, :string
    add_column :games, :initially_released_at, :datetime
  end

  def self.down
  end
end
