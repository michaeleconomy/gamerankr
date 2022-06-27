class Follow < ApplicationRecord

  belongs_to :follower, foreign_key: "follower_id", class_name: "User", counter_cache: :following_count
  belongs_to :following, foreign_key: "following_id", class_name: "User", counter_cache: :follower_count
  validates_uniqueness_of :following_id, scope: :follower_id
  validate :validate_following_count

  MAX_FOLLOWINGS = 500

  def validate_following_count
    if follower.following_count >= MAX_FOLLOWINGS
      errors.add "Cannot follow more than #{MAX_FOLLOWINGS} people."
    end
  end

  def self.MAX_FOLLOWINGS
    MAX_FOLLOWINGS
  end
end
