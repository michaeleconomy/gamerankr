class MoreRankingsColumnChanges < ActiveRecord::Migration
  def self.up
    add_column :rankings, :finished_at, :datetime
    rename_column :rankings, :played_at, :started_at
  end

  def self.down
  end
end
