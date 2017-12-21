Types::ShelfType = GraphQL::ObjectType.define do
  name "Shelf"
  field :id, !types.ID
  field :name, !types.String
  connection :rankings, !Types::RankingType.connection_type do
    resolve -> (obj, args, ctx) do
      obj.rankings.order("id desc")
    end
  end
end