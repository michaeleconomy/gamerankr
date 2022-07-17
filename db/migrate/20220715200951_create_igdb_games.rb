class CreateIgdbGames < ActiveRecord::Migration[7.0]
  def change
    create_table :igdb_games do |t|
      t.string :igdb_id, null: false
      t.string :description
      t.string :cover_image_id
      t.timestamps
      t.index :igdb_id, unique: true
    end
  end
end
