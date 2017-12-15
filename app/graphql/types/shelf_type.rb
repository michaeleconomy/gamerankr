Types::ShelfType = GraphQL::ObjectType.define do
  name "Shelf"
  field :id, !types.ID
  field :name, !types.String
  field :rankings, !types[!Types::RankingType]
end