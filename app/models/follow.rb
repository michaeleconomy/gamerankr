class Follow < ApplicationRecord

  belongs_to :follower, :foreign_key => "follower_id", :class_name => "User"
  belongs_to :following, :foreign_key => "following_id", :class_name => "User"
  validates_uniqueness_of :following_id, :scope => :follower_id
end
