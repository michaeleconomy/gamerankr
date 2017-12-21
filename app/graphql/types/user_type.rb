Types::UserType = GraphQL::ObjectType.define do
  name "User"
  field :id, !types.ID
  field :real_name, !types.String
  connection :rankings, !Types::RankingType.connection_type do
    resolve -> (obj, args, ctx) do
      obj.rankings.order("id desc")
    end
  end
  field :shelves, !types[!Types::ShelfType] do
    resolve -> (obj, args, ctx) do
      obj.shelves.where("ranking_shelves_count > 0")
    end
  end
  field :photo_url, !types.String do
    resolve -> (obj, args, ctx) do
      RecordLoader.for(Authorization, :user_id).load(obj.id).then do |fb_user|
        fb_user.photo_url
      end
    end

  end
end