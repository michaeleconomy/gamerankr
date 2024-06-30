class ChangeItunesTrackIdString < ActiveRecord::Migration[7.0]
  def change
    change_column :itunes_ports, :track_id, :string
  end
end
