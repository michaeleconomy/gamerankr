Types::RankingType = GraphQL::ObjectType.define do
  name "Ranking"
  field :id, !types.ID
  field :game, !Types::GameType do
    resolve -> (obj, args, ctx) {
      RecordLoader.for(Game).load(obj.game_id)
    }
  end
  field :user, !Types::UserType
  field :review, types.String
  field :ranking, types.Int
  field :shelves, types[Types::ShelfType]
end