Types::GameType = GraphQL::ObjectType.define do
  name "Game"
  field :id, !types.ID
  field :title, !types.String
  field :rankings, !types[!Types::RankingType]
  field :ports, !types[!Types::PortType] do
    resolve -> (obj, args, ctx) {
      HasManyRecordLoader.for(Port, :game_id).load(obj.id)
    }
  end
end