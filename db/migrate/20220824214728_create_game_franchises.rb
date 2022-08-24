class CreateGameFranchises < ActiveRecord::Migration[7.0]
  def change
    create_table :game_franchises do |t|
      t.integer :game_id, null: false
      t.integer :franchise_id, null: false
      t.timestamps
      t.index [:game_id, :franchise_id], unique: true
      t.index :franchise_id
    end
  end
end
