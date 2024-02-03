class IndexPublisherGamesOnPublisherId < ActiveRecord::Migration[7.0]
  def change
    add_index :publisher_games, :publisher_id
  end
end
