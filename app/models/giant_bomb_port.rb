class GiantBombPort < ApplicationRecord
  include GiantBombImages

  has_many :ports, :as => :additional_data

  validates_presence_of :giant_bomb_id, :url

  def port
    ports.first
  end

end
