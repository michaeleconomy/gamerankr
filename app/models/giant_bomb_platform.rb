class GiantBombPlatform < ApplicationRecord
  include GiantBombImages

  validates_presence_of :giant_bomb_id, :url, :image_id
  
  belongs_to :platform
end
