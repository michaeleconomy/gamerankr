class GameAlternateNames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :alternate_names, :string, null: false, default: ""
  end
end
