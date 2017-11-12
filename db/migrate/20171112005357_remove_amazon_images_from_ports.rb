class RemoveAmazonImagesFromPorts < ActiveRecord::Migration[5.1]
  def change
  	remove_column :ports, :amazon_image_url, :string
  end
end
