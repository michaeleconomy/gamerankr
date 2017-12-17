Types::GameType = GraphQL::ObjectType.define do
  name "Game"
  field :id, !types.ID
  field :title, !types.String
  field :rankings, !types[!Types::RankingType] do
    argument :limit, types.Int, default_value: 30
    
    rs = ResolverStacker.new do |obj, args, ctx|
      obj.rankings.order("id desc")
    end.paginate
    resolve rs.r
  end
  field :ports, !types[!Types::PortType] do
    resolve -> (obj, args, ctx) {
      HasManyRecordLoader.for(Port, :game_id).load(obj.id)
    }
  end
end