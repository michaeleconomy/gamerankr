class FixNullOnRankingRanking < ActiveRecord::Migration
  def self.up
    change_column :rankings, :ranking, :integer, :null => true
  end

  def self.down
  end
end
