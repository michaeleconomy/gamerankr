class User < ActiveRecord::Base
  has_secure_password

  def self.email_regex
    /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i
  end
  
  validates_format_of :email, with: email_regex, if: lambda {|u| u.email }
  validates_format_of :real_name, with: /[^\s]+/
  validates_uniqueness_of :email, if: lambda {|u| u.email }

  has_many :authorizations, dependent: :destroy
  has_one :facebook_user, -> { where(provider: 'facebook') },
    class_name: "Authorization"
  has_one :ios_authorization, -> { where(provider: 'gamerankr-ios')},
    class_name: "Authorization"
  has_many :web_authorizations, -> { where(provider: 'web')},
    class_name: "Authorization"
  has_one :password_reset_request, dependent: :destroy

  has_many :rankings, dependent: :destroy
  has_many :shelves, dependent: :destroy
  has_many :emails, dependent: :destroy

  has_many :followers,
    dependent: :destroy,
    class_name: "Follow",
    foreign_key: "following_id"
  has_many :followings,
    dependent: :destroy,
    class_name: "Follow",
    foreign_key: "follower_id"

  has_many :user_profile_questions, dependent: :destroy
  has_one :admin, dependent: :destroy
  has_many :comments
  has_many :recommendations, dependent: :destroy

  has_one :password_reset_request, dependent: :destroy
  
  accepts_nested_attributes_for :user_profile_questions,
    reject_if: proc {|attributes| attributes[:question].blank? || attributes[:answer].blank?},
    allow_destroy: true
    
  before_save do
    if email_changed?
      self.bounce_count = 0
      self.last_bounce_at = nil
    end
  end

  after_create do |user|
    Shelf::DEFAULT_NAMES.each do |name|
      user.shelves.create :name => name
    end
  end

  # name, default, allowed values
  PREFERENCES = [
    [:comment_notification_email, true, [true, false]],
    [:friend_update_email, true, [true, false]],
    [:new_follower_email, true, [true, false]],
  ]

  PREFERENCE_VALUES_MAP = {
    true => "t",
    false => "f"
  }

  PREFERENCE_VALUES_MAP_REVERSE = PREFERENCE_VALUES_MAP.invert

  PREFERENCES.each_with_index do |preference_array, i|
    preference, default, allowed_values = preference_array
    define_method preference do
      raw_value = preferences[i]
      PREFERENCE_VALUES_MAP_REVERSE.member?(raw_value) ? PREFERENCE_VALUES_MAP_REVERSE[raw_value] : default
    end

    define_method "#{preference}=" do |value|
      if value == "0"
        value = false
      end
      if value == "1"
        value = true
      end
      raw_value = PREFERENCE_VALUES_MAP[value]
      if !raw_value
        return
      end
      while self.preferences.length < i
        self.preferences += "?"
      end
      self.preferences[i] = raw_value
    end

    validates_inclusion_of preference, in: allowed_values
  end
  
  def first_name
    real_name[/\w+/]
  end
  
  def to_display_name
    real_name
  end

  def following_user_ids
    followings.pluck(:following_id)
  end

  def photo_url(size = nil)
    return nil if !facebook_user
    facebook_user.photo_url(size)
  end
  
  def to_param
    "#{id}-#{real_name.gsub(/[^\w]/, '-')}"
  end

  def updates
    Ranking.where(user_id: following_user_ids).
      order("updated_at desc")
  end

  def email_bounced?
    bounce_count > 0
  end

  def verified?
    verified_at
  end

  def recieves_emails?
    email && !email_bounced? && verified?
  end
end
