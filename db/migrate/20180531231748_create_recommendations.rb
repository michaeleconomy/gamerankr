class CreateRecommendations < ActiveRecord::Migration[5.2]
  def change
    create_table :recommendations do |t|
      t.integer :user_id, :null => false
      t.integer :game_id, :null => false
      t.integer :algorithm, :null => false
      t.float :score, :null => false
      t.timestamps
      t.index [:user_id, :score]
      t.index [:game_id, :user_id, :algorithm], unique: true
    end
  end
end
