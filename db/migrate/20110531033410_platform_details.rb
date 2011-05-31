class PlatformDetails < ActiveRecord::Migration
  def self.up
    add_column :platforms, :description, :string, :limit => 4000
    add_column :platforms, :released_at, :date
    add_column :platforms, :portable, :boolean, :default => false
    add_column :platforms, :generation, :integer
  end

  def self.down
    remove_column :platforms, :description, :released_at, :portable, :generation
  end
end
