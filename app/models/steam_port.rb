class SteamPort < ActiveRecord::Base
  has_one :port, as: :additional_data

  validates_presence_of :steam_id
  
  #http://cdn2.steampowered.com/v/gfx/apps/214933/header_292x136.jpg
  #http://cdn2.steampowered.com/v/gfx/apps/212680/capsule_sm_120.jpg
  #http://cdn2.steampowered.com/v/gfx/apps/113020/capsule_616x353.jpg
  #http://cdn2.steampowered.com/v/gfx/apps/204360/capsule_184x69.jpg
  # imageSizes
  #
  
  def resized_image_url(size)
    size_px = size.gsub(/[^\d]/, "").to_i
    size_code = 
      if size_px <= 120
        "capsule_sm_120"
      elsif size_px <= 184
        "capsule_184x69"
      elsif size_px <= 292
        "header_292x136"
      else
        "capsule_616x353"
      end
        
    steam_image_url(size_code)
  end
  
  def steam_image_url(size)
    "http://cdn2.steampowered.com/v/gfx/apps/#{steam_id}/#{size}.jpg"
  end

  def affiliate_url
    "http://store.steampowered.com/app/#{steam_id}/"
  end


  def small_image_url
    steam_image_url("capsule_sm_120")
  end

  def medium_image_url
    steam_image_url("header_292x136")
  end
  
  def large_image_url
    steam_image_url("capsule_616x353")
  end
end
