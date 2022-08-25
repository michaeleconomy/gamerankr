class RemovePortIdsFromDeveloperPublisher < ActiveRecord::Migration[7.0]
  def change
    DeveloperGame.delete_all
    Developer.delete_all

    remove_column :developer_games, :port_id
    add_index :developer_games, [:game_id, :developer_id], unique: true
    add_index :developer_games, :developer_id

    PublisherGame.delete_all
    Publisher.delete_all
    remove_column :publisher_games, :port_id
    add_index :publisher_games, [:game_id, :publisher_id], unique: true
  end
end
