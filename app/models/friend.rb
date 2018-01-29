class Friend < ApplicationRecord
  belongs_to :user
  belongs_to :friend_user, :foreign_key => "friend_id", :class_name => "User"

  validates_uniqueness_of :user_id, :scope => :friend_id


  def self.make(user_id1, user_id2)
    begin
      find_or_create_by!(user_id: user_id1, friend_id: user_id2)
    rescue ActiveRecord::RecordNotUnique => e
      # ok, operation is not unique accross requests
    end

    begin
      find_or_create_by!(user_id: user_id2, friend_id: user_id1)
    rescue ActiveRecord::RecordNotUnique => e
      # ok, operation is not unique accross requests
    end
  end

  def self.unmake(user_id1, user_id2)
    where(user_id: user_id1, friend_id: user_id2).destroy_all
    where(user_id: user_id2, friend_id: user_id1).destroy_all
  end

end
