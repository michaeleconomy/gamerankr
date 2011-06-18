class ItunesPort < ActiveRecord::Base
  has_one :port, :as => :additional_data
  
  validates_presence_of :url
  validates_presence_of :track_id
  
  
  def resized_image_url(size)
    size_px = size.gsub(/[^\d]/, "").to_i
    if size_px <= 57
      small_image_url
    elsif size_px <= 100
      medium_image_url
    else
      large_image_url
    end
  end
  
  def affiliate_url
    url
  end
end
