class Authorization < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id, :uid, :provider
  validates_uniqueness_of :uid, scope: :provider
  
  
  def self.facebook
    where("provider=?", 'facebook')
  end
  
  def self.by_uid(uids)
    where('uid in (?)', uids)
  end

  def photo_url(size = nil)
    return nil if provider != "facebook"
    url = 'https://graph.facebook.com/' + uid + '/picture'
    if size
      url += "?type=#{size}"
    end
    # TODO, support the width and height parameters also!
    url
  end
end
