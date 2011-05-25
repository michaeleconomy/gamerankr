class User < ActiveRecord::Base
  has_many :authorizations
  has_many :comments, :dependent => :destroy
  has_many :rankings, :dependent => :destroy
  has_many :shelves, :dependent => :destroy
  has_many :emails, :dependent => :destroy
  has_many :user_profile_questions, :dependent => :destroy
  has_one :admin, :dependent => :destroy
  
  accepts_nested_attributes_for :user_profile_questions, :allow_destroy => true
  
  after_create do |user|
    Shelf::DEFAULT_NAMES.each do |name|
      user.shelves.create :name => name
    end
  end
  
  def first_name
    real_name[/\w+/]
  end
  
  def to_display_name
    real_name
  end
end
