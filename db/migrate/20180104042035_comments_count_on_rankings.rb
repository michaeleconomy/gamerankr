class CommentsCountOnRankings < ActiveRecord::Migration[5.1]
  def change
    add_column :rankings, :comments_count, :integer, :null => false, :default => 0
    Comment.group(:resource_id).pluck("resource_id, count(1)").each do |id, count|
      r = Ranking.find(id)
      r.comments_count = count
      r.save!
    end
    add_index :rankings, [:user_id, :game_id], :unique => true
    add_index :rankings, :game_id
    add_index :rankings, :port_id
  end
end
