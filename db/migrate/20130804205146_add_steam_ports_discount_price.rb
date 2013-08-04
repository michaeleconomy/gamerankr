class AddSteamPortsDiscountPrice < ActiveRecord::Migration
  def change
    add_column :steam_ports, :discount_price, :integer
  end
end
