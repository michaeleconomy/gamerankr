class Email < ActiveRecord::Base

  def self.regex
    /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i
  end

  belongs_to :user
  validates_format_of :email, :with => regex
  validates_uniqueness_of :email
  after_save :if => lambda {saved_change_to_primary && primary} do
    user.emails.where("id != ?", id).update_all(primary: false)
  end

    
  before_save do
    if email_changed?
      self.bounce_count = 0
      self.last_bounce_at = nil
    end
  end

  def bounced?
    bounce_count > 0
  end
end
