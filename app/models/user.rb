class User < ActiveRecord::Base
  has_many :authorizations, :dependent => :destroy
  has_one :facebook_user, -> { where("provider = 'facebook'")},
    :class_name => "Authorization"
  has_many :rankings, :dependent => :destroy
  has_many :shelves, :dependent => :destroy
  has_many :emails, :dependent => :destroy
  has_many :user_profile_questions, :dependent => :destroy
  has_one :admin, :dependent => :destroy
  
  accepts_nested_attributes_for :user_profile_questions,
    reject_if: proc {|attributes| attributes[:question].blank? || attributes[:answer].blank?},
    :allow_destroy => true

  accepts_nested_attributes_for :emails,
    reject_if: proc {|attributes| attributes[:email].blank?},
    :allow_destroy => true
  
  after_create do |user|
    Shelf::DEFAULT_NAMES.each do |name|
      user.shelves.create :name => name
    end
  end

  after_create_commit {WelcomeJob.perform_in(30, id)}

  # name, default, allowed values
  PREFERENCES = [
    [:comment_notification_email, true, [true, false]],
    [:friend_update_email, true, [true, false]]
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

    validates_inclusion_of preference, :in => allowed_values
  end
  
  def first_name
    real_name[/\w+/]
  end
  
  def to_display_name
    real_name
  end
  
  def email
    emails.first.email
  end
  
  
  def to_param
    "#{id}-#{real_name.gsub(/[^\w]/, '-')}"
  end
end
