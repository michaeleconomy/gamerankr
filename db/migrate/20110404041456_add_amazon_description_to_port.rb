class AddAmazonDescriptionToPort < ActiveRecord::Migration
  def self.up
    add_column :ports, :amazon_description, :text
  end

  def self.down
    remove_column :ports, :amazon_description
  end
end
