Types::QueryType = GraphQL::ObjectType.define do
  name "Query"
 
  connection :my_games, !Types::RankingType.connection_type do
    description "get games the current user has added"
    resolve ResolverErrorHandler.new -> (obj, args, ctx) do
      ctx[:current_user].rankings.order("id desc")
    end
  end

  field :game do
    type !Types::GameType
    argument :id, !types.ID
    resolve ResolverErrorHandler.new ->(obj, args, ctx) {
      Game.find(args[:id])
    }
  end

  field :shelf do
    type !Types::ShelfType
    argument :id, !types.ID
    resolve ResolverErrorHandler.new ->(obj, args, ctx) {
      Shelf.find(args[:id])
    }
  end

  field :user do
    type !Types::UserType
    argument :id, !types.ID
    resolve ResolverErrorHandler.new ->(obj, args, ctx) {
      User.find(args[:id])
    }
  end

  field :me do
    type !Types::UserType
    resolve ResolverErrorHandler.new ->(obj, args, ctx) {
      ctx[:current_user]
    }
  end

  field :my_shelves do
    type !types[!Types::ShelfType]
    resolve ResolverErrorHandler.new ->(obj, args, ctx) {
      ctx[:current_user].shelves
    }
  end
  
  connection :comments, !Types::CommentType.connection_type do
    argument :resource_type, !types.String
    argument :resource_id,  !types.ID
    resolve ResolverErrorHandler.new -> (obj, args, ctx) do
      case args[:resource_type]
      when "Ranking"
        return Ranking.find(args[:resource_id]).comments.order("comments.id")
      else
        raise "unknown type: #{args[:resource_type]}"
      end
    end
  end

  connection :updates, !Types::RankingType.connection_type do
    resolve ResolverErrorHandler.new -> (obj, args, ctx) do
      ctx[:current_user].updates
    end
  end

  connection :friends, !Types::UserType.connection_type  do
    resolve ResolverErrorHandler.new -> (obj, args, ctx) do
      User.where(id: ctx[:current_user].friend_user_ids).order(:real_name)
    end
  end
  
  connection :search, !Types::GameType.connection_type do
    argument :query, !types.String
    description "get games matching the query string"
    resolve ResolverErrorHandler.new ->(obj, args, ctx) do
      page = args[:after] && GraphQL::Schema::Base64Encoder.decode(args[:after]).to_s || 1
      Search::GameRankrElasticSearch.for(args[:query], page: page)
    end
  end

  #browse section
  field :popular_games, !types[!Types::GameType] do
    resolve ResolverErrorHandler.new -> (obj, args, ctx) do
      Game.popular
    end
  end

  field :featured_platforms, !types[!Types::PlatformType] do
    resolve ResolverErrorHandler.new -> (obj, args, ctx) do
      Platform.featured
    end
  end

  connection :platforms, !Types::PlatformType.connection_type do
    resolve ResolverErrorHandler.new -> (obj, args, ctx) do
      Platform.order("name")
    end
  end

  connection :recent_reviews, !Types::RankingType.connection_type do
    resolve ResolverErrorHandler.new -> (obj, args, ctx) do
      Ranking.recent_reviews
    end
  end
end
