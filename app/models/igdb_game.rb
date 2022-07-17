class IgdbGame < ApplicationRecord
  has_many :ports, as: :additional_data
  validates_presence_of :igdb_id


  # https://images.igdb.com/igdb/image/upload/t_thumb/co448a.jpg
  # https://images.igdb.com/igdb/image/upload/t_cover_big/co448a.jpg
  IMAGE_PREFIX = "https://images.igdb.com/igdb/image/upload/"

  def resized_image_url(size)
    size_px = size.gsub(/[^\d]/, "").to_i
    if size_px <= 100
      icon_image_url
    else
      medium_image_url
    end
  end
  
  def icon_image_url
    cover_image_id && "#{IMAGE_PREFIX}t_thumb/#{cover_image_id}.jpg"
  end

  def medium_image_url
    cover_image_id && "#{IMAGE_PREFIX}t_cover_big/#{cover_image_id}.jpg"
  end

  def original_image_url
    medium_image_url
  end

  def large_image_url
    original_image_url
  end

  def small_image_url
    icon_image_url
  end
end
