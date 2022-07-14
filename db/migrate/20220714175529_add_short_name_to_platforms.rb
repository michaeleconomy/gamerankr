class AddShortNameToPlatforms < ActiveRecord::Migration[7.0]
  def change
    add_column :platforms, :short_name, :string
  end
end
