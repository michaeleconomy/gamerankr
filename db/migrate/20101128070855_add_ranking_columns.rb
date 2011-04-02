class AddRankingColumns < ActiveRecord::Migration
  def self.up
    add_column :rankings, :review, :text
    add_column :rankings, :played_at, :datetime
  end

  def self.down
  end
end
