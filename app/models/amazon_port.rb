class AmazonPort < ActiveRecord::Base
  has_one :port, :as => :additional_data
  
  
  validates_presence_of :asin
  validates_presence_of :url
  
  def resized_image_url(size)
    return unless image_url
    image_url.sub(".jpg", "._#{size}_.jpg").sub(".gif", "._#{size}_.gif")
  end
  
  def affiliate_url
    url + "&tag=gamerankr-20"
  end
end