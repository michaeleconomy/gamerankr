class AndroidMarketplacePort < ActiveRecord::Base
  has_one :port, :as => :additional_data

  validates_presence_of :url
  validates_presence_of :am_id
  
  def resized_image_url(size)
    image_url
  end

  def small_image_url
    image_url
  end

  def affiliate_url
    url
  end
end
