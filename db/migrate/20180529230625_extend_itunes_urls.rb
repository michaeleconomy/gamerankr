class ExtendItunesUrls < ActiveRecord::Migration[5.2]
  def up
    change_column :itunes_ports, :url, :string, :limit => 512
    change_column :itunes_ports, :small_image_url, :string, :limit => 512
    change_column :itunes_ports, :medium_image_url, :string, :limit => 512
    change_column :itunes_ports, :large_image_url, :string, :limit => 512
  end

  def down
    change_column :itunes_ports, :url, :string, :limit => 256
    change_column :itunes_ports, :small_image_url, :string, :limit => 256
    change_column :itunes_ports, :medium_image_url, :string, :limit => 256
    change_column :itunes_ports, :large_image_url, :string, :limit => 256
  end
end
