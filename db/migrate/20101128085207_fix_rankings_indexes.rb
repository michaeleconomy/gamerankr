class FixRankingsIndexes < ActiveRecord::Migration
  def self.up
    begin
      remove_index :rankings, [:user_id, :resource_id, :resource_type]
    rescue => e
      Rails.logger.info "#{e}"
    end
  end

  def self.down
  end
end
