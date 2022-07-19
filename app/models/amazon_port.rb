class AmazonPort < ActiveRecord::Base
  has_one :port, as: :additional_data
  
  
  validates_presence_of :asin
  validates_presence_of :url
  
  def resized_image_url(size)
    return unless image_url

    image_url.sub(".jpg", "._#{size}_.jpg").sub(".gif", "._#{size}_.gif").sub("http://ecx.images-amazon.com", "https://images-na.ssl-images-amazon.com")
  end

  def small_image_url
    resized_image_url("SX100")
  end

  def medium_image_url
    resized_image_url("SX250")
  end
  
  def large_image_url
    image_url
  end
  
  def affiliate_url
    if url =~ /&tag=gamerankr-20/
      url
    else
      url + "&tag=gamerankr-20"
    end
  end
end
