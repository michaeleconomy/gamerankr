class Email < ActiveRecord::Base
  belongs_to :user
  validates_format_of :email, :with => /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i

  before_save do
    if email_changed?
      bounce_count += 1
      last_bounce_at = nil
    end
  end

  def bounced?
    bounce_count > 0
  end
end
