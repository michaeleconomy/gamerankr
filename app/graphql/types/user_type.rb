Types::UserType = GraphQL::ObjectType.define do
  name "User"
  field :id, !types.ID
  field :real_name, !types.String
  field :rankings, !types[!Types::RankingType] do
    argument :limit, types.Int, default_value: 30
    
    rs = ResolverStacker.new do |obj, args, ctx|
      obj.rankings.order("id desc")
    end.paginate
    resolve rs.r
  end
  field :shelves, !types[!Types::ShelfType] do
    resolve do |obj, args, ctx|
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