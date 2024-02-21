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
end
