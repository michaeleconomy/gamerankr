Types::UserType = GraphQL::ObjectType.define do
  name "User"
  field :id, !types.ID
  field :real_name, !types.String
  field :rankings, types[Types::RankingType] do
    argument :limit, types.Int, default_value: 30
    
    rs = ResolverStacker.new do |obj, args, ctx|
      obj.rankings
    end.paginate
    resolve rs.r
  end
  field :shelves, types[Types::ShelfType]
end