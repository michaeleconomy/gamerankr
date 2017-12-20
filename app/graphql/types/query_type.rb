Types::QueryType = GraphQL::ObjectType.define do
  name "Query"
  # Add root-level fields here.
  # They will be entry points for queries on your schema.

  connection :my_games, !Types::RankingType.connection_type do
    # argument :limit, types.Int, default_value: 30
    # argument :offset, types.Int
    
    description "get games the current user has added"
    
    # type !types[!Types::RankingType]
    # rs = ResolverStacker.new do |obj, args, ctx|
    #   ctx[:current_user].rankings
    # end.paginate

    # resolve rs.r
    resolve -> (obj, args, ctx) do
      ctx[:current_user].rankings
    end
  end

  field :game do
    type !Types::GameType
    argument :id, !types.ID
    resolve ->(obj, args, ctx) {
      Game.find(args[:id])
    }
  end

  field :user do
    type !Types::UserType
    argument :id, !types.ID
    resolve ->(obj, args, ctx) {
      User.find(args[:id])
    }
  end

  field :me do
    type !Types::UserType
    resolve ->(obj, args, ctx) {
      ctx[:current_user]
    }
  end


  field :my_shelves do
    type !types[!Types::ShelfType]
    resolve ->(obj, args, ctx) {
      ctx[:current_user].shelves
    }
  end

  connection :updates, !Types::RankingType.connection_type do
    # type !types[!Types::RankingType]
    # argument :limit, types.Int, default_value: 30
    # argument :offset, types.Int
    # rs = ResolverStacker.new do |obj, args, ctx|
    #   ctx[:current_user].updates
    # end.paginate

    # resolve rs.r

    resolve -> (obj, args, ctx) do
      ctx[:current_user].updates
    end
  end

  connection :friends, !Types::UserType.connection_type  do
    # type !types[!Types::UserType]
    # argument :limit, types.Int, default_value: 30
    # argument :offset, types.Int
    # rs = ResolverStacker.new do |obj, args, ctx|
    #   User.where(id: ctx[:current_user].friend_user_ids).order(:real_name)
    # end.paginate

    # resolve rs.r
    resolve -> (obj, args, ctx) do
      User.where(id: ctx[:current_user].friend_user_ids).order(:real_name)
    end
  end
  
  field :search do
    type !types[!Types::GameType]
    argument :query, !types.String
    description "get games matching the query string"
    resolve ->(obj, args, ctx) { Search::GameRankrSearch.for(args[:query]) }
  end

end
