module GiantBombImages

  IMAGE_PREFIX = "https://www.giantbomb.com/api/image/"
  

  def resized_image_url(size)
    size_px = size.gsub(/[^\d]/, "").to_i
    if size_px <= 100
      icon_image_url
    else
      medium_image_url
    end
  end
  
  def icon_image_url
    "#{IMAGE_PREFIX}square_avatar/#{image_id}"
  end

  def medium_image_url
    "#{IMAGE_PREFIX}scale_small/#{image_id}"
  end

  def original_image_url
    "#{IMAGE_PREFIX}original/#{image_id}"
  end

  def large_image_url
    original_image_url
  end

  def small_image_url
    icon_image_url
  end
end