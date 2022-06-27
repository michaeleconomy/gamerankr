class FriendsToFollow < ActiveRecord::Migration[7.0]
  def change
    Friend.all.each do |f|
      follow = Follow.new(follower_id: f.user_id, following_id: f.friend_id)
      follow.surpress_email = true
      follow.save!
    end
  end
end
