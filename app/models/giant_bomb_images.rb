module GiantBombImages

  IMAGE_PREFIX_OLD = "https://www.giantbomb.com/api/image/"
  IMAGE_PREFIX = "https://giantbomb1.cbsistatic.com/uploads/"

  # https://giantbomb1.cbsistatic.com/uploads/scale_small/0/3699/2749429-assassin%27s%20creed%20-%20syndicate.jpg
  # https://www.giantbomb.com/api/image/scale_small/2732892-rsz_1image.jpg
  # https://giantbomb1.cbsistatic.com/uploads/scale_small/18/187968/2732892-rsz_1image.jpg

  def resized_image_url(size)
    size_px = size.gsub(/[^\d]/, "").to_i
    if size_px <= 100
      icon_image_url
    else
      medium_image_url
    end
  end
  
  def icon_image_url
    image_id && "#{image_prefix}square_avatar/#{image_id}"
  end

  def medium_image_url
    image_id && "#{image_prefix}scale_small/#{image_id}"
  end

  def original_image_url
    image_id && "#{image_prefix}original/#{image_id}"
  end

  def large_image_url
    original_image_url
  end

  def small_image_url
    icon_image_url
  end

  private

  def image_prefix
    if image_id.include?("/")
      return IMAGE_PREFIX
    end
    IMAGE_PREFIX_OLD
  end

end