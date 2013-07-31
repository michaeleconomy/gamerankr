class SteamPort < ActiveRecord::Base
  has_one :port, :as => :additional_data

  validates_presence_of :steam_id
  
  #http://cdn2.steampowered.com/v/gfx/apps/214933/header_292x136.jpg
  #http://cdn2.steampowered.com/v/gfx/apps/212680/capsule_sm_120.jpg
  #http://cdn2.steampowered.com/v/gfx/apps/113020/capsule_616x353.jpg
  #http://cdn2.steampowered.com/v/gfx/apps/204360/capsule_184x69.jpg
  # imageSizes
  #
  
  
  def resized_image_url(size)
    image_url
  end

  def affiliate_url
    "http://store.steampowered.com/app/#{steam_id}/"
  end
end
