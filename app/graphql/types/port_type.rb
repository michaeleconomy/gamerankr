Types::PortType = GraphQL::ObjectType.define do
  name "Port"
  field :id, !types.ID
  field :game, !Types::GameType
  field :platform, !Types::PlatformType
  field :title, !types.String
  field :rankings, !types[!Types::RankingType]
end