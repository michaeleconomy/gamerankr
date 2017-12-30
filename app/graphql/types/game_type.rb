Types::GameType = GraphQL::ObjectType.define do
  name "Game"
  field :id, !types.ID
  field :title, !types.String
  connection :rankings, !Types::RankingType.connection_type do
    resolve -> (obj, args, ctx) do
      obj.rankings.order("id desc")
    end
  end
  field :friend_rankings, !types[!Types::RankingType] do
    resolve -> (obj, args, ctx) do
      if ctx[:current_user] == FakeCurrentUser
        []
      else
        obj.rankings.where(user_id: ctx[:current_user].friend_user_ids).order("id desc")
      end
    end
  end
  field :ports, !types[!Types::PortType] do
    resolve -> (obj, args, ctx) do
      HasManyRecordLoader.for(Port, :game_id).load(obj.id)
    end
  end

end