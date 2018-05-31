class CreateSimularGames < ActiveRecord::Migration[5.2]
  def change
    create_table :simular_games do |t|
      t.integer :game_id, :null => false
      t.integer :simular_game_id, :null => false
      t.integer :version, :null => false
      t.integer :algorithm, :null => false
      t.float :score, :null => false
      t.timestamps
      t.index [:game_id, :score]
      t.index [:simular_game_id, :game_id, :version], :unique => true
    end
  end
end
