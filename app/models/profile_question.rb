class ProfileQuestion < ActiveRecord::Base
  belongs_to :created_by_user, :class_name => "User"
  has_many :user_profile_questions, :dependent => :destroy
  
  validates_length_of :question, :in => 2..4000
  validates_uniqueness_of :question
  validates_presence_of :created_by_user
  
  def self.shown
    where(:shown => true)
  end
end
