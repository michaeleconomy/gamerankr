class AddRankingsCountToPort < ActiveRecord::Migration
  def self.up
    add_column :ports, :rankings_count, :integer, :null => false, :default => 0
    
    Port.all.each do |p|
      Port.update_all(["rankings_count = ?", p.rankings.count], ["id = ?", p.id])
    end
  end

  def self.down
    remove_column :ports, :rankings_count
  end
end
