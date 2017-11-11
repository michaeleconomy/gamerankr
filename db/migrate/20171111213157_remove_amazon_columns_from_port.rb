class RemoveAmazonColumnsFromPort < ActiveRecord::Migration[5.1]
  def change
  	remove_column :ports, :amazon_description, :string
  	remove_column :ports, :amazon_price, :int
  	remove_column :ports, :amazon_url, :string
  	remove_column :ports, :amazon_updated_at, :date
  	remove_column :ports, :binding, :string
  end
end
