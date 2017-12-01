class CreateGiantBombPlatforms < ActiveRecord::Migration[5.1]
  def change
    create_table :giant_bomb_platforms do |t|
      t.integer :platform_id, :null => false, :index => {:unique => true}
      t.integer :giant_bomb_id, :null => false, :index => {:unique => true}
      t.string :image_id
      t.integer :install_base
      t.integer :original_price
      t.boolean :online
      t.string :url, :null => false
      t.timestamps
    end
  end
end
