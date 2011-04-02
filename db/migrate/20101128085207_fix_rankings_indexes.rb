class FixRankingsIndexes < ActiveRecord::Migration
  def self.up
    remove_index :rankings, :name => 'index_rankings_on_user_id_and_resource_id_and_resource_type'
  end

  def self.down
  end
end
