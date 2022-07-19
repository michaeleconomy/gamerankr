class Types::UserType < Types::BaseObject
  graphql_name "User"
  field :id, ID, null: false
  field :real_name, String, null: false, camelize: false
  field :rankings, Types::RankingType.connection_type, null: false
  def rankings
    object.rankings.order("id desc")
  end
  
  field :shelves, [Types::ShelfType, null: false], null: false 
  def shelves
    object.shelves.where("ranking_shelves_count > 0")
  end

  field :photo_url, String, null: false, camelize: false
  def photo_url
    @facebook_record_loader ||= RecordLoader.for(Authorization.where(provider: 'facebook'), :user_id)
    @facebook_record_loader.load(object.id).then do |fb_user|
      fb_user ? fb_user.photo_url : ActionController::Base.helpers.asset_url("default_profile.jpg")
    end
  end
end