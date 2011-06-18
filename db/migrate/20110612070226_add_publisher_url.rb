class AddPublisherUrl < ActiveRecord::Migration
  def self.up
    add_column :publishers, :url, :string, :limit => 256
  end

  def self.down
    remove_column :publishers, :url
  end
end
