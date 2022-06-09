class Types::GameType < Types::BaseObject
  graphql_name "Game"
  field :id, ID, null: false
  field :title, String, null: false
  
  field :rankings, Types::RankingType.connection_type, null: false
  def rankings
    object.rankings.order("id desc")
  end

  field :friend_rankings, [Types::RankingType, null: false], null: false, :camelize => false
  def friend_rankings
    if context[:current_user] == FakeCurrentUser
      []
    else
      obj.rankings.where(user_id: context[:current_user].friend_user_ids).order("id desc")
    end
  end

  field :ports, [Types::PortType, null: false], null: false 
  def ports
    HasManyRecordLoader.for(Port, :game_id).load(object.id)
  end

  field :url, String, null: false
  def url
    context[:controller].game_url(object)
  end
  field :description, String
end