class Types::ShelfType < Types::BaseObject
  graphql_name "Shelf"
  field :id, ID, null: false
  field :name, String, null: false
  field :rankings, Types::RankingType.connection_type, null: false
  def rankings
    object.rankings.order("rankings.id desc")
  end
end