class Types::UserType < Types::BaseObject
  graphql_name "User"
  field :id, ID, null: false
  field :real_name, String, null: false, camelize: false
  field :rankings_count, Int, null: false
  field :follower_count, Int, null: false
  field :following_count, Int, null: false
  field :rankings, Types::RankingType.connection_type, null: false
  def rankings
    object.rankings.order("id desc")
  end
  
  field :shelves, [Types::ShelfType, null: false], null: false 
  def shelves
    object.shelves.where("ranking_shelves_count > 0")
  end

  field :following_user_ids, [ID, null: false], null: false 
  def following
    object.following_user_ids
  end

  field :following, Types::UserType.connection_type, null: false 
  def following
    object.following_users.order("real_name")
  end
  
  field :followers, Types::UserType.connection_type, null: false 
  def followers
    object.follower_users.order("real_name")
  end

  field :photo_url, String, null: false, camelize: false
  def photo_url
    @facebook_record_loader ||= RecordLoader.for(Authorization.where(provider: 'facebook'), :user_id)
    @facebook_record_loader.load(object.id).then do |fb_user|
      fb_user ? fb_user.photo_url : ActionController::Base.helpers.asset_url("default_profile.jpg")
    end
  end
end