Types::GameType = GraphQL::ObjectType.define do
  name "Game"
  field :id, !types.ID
  field :title, !types.String
  field :rankings, !types[!Types::RankingType]
  field :ports, !types[!Types::PortType]
end