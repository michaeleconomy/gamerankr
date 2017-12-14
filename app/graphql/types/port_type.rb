Types::PortType = GraphQL::ObjectType.define do
  name "Port"
  field :id, !types.ID
  field :title, !types.String
  field :game, Types::GameType
  field :rankings, types[Types::RankingType]
end