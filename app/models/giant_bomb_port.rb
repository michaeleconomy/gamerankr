class GiantBombPort < ApplicationRecord
	IMAGE_PREFIX = "https://www.giantbomb.com/api/image/"

  has_many :ports, :as => :additional_data

  validates_presence_of :giant_bomb_id, :url, :image_id

  def port
    ports.first
  end

  def resized_image_url(size)
    size_px = size.gsub(/[^\d]/, "").to_i
    if size_px <= 57
      icon_image_url
    elsif size_px <= 100
      medium_image_url
    else
      original_image_url
    end
  end

  def icon_image_url
  	"#{IMAGE_PREFIX}square_avatar/#{image_id}"
  end

  def medium_image_url
  	"#{IMAGE_PREFIX}scale_medium/#{image_id}"
  end

  def original_image_url
    "#{IMAGE_PREFIX}original/#{image_id}"
  end

  def large_image_url
    original_image_url
  end


end
