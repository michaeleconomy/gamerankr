class AddMoreDataColumns < ActiveRecord::Migration
  def self.up
    add_column :ports, :upc, :string
    add_column :ports, :ean, :string
    add_column :ports, :manufacturer, :string
    add_column :ports, :title, :string
    add_column :ports, :released_at_accuracy, :string
    add_column :ports, :brand, :string
    add_column :ports, :amazon_price, :integer
    add_column :ports, :amazon_url, :string
    add_column :ports, :amazon_updated_at, :datetime
    add_column :ports, :amazon_image_url, :string
    add_column :developer_games, :port_id, :integer, :null => false
  end

  def self.down
    remove_column :ports, :upc, :ean, :manufacturer, :title, :released_at_accuracy,
      :brand, :amazon_price, :amazon_url, :amazon_image_url, :amazon_updated_at
    remove_column :developer_games, :port_id
  end
end
