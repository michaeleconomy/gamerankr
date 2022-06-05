module Types
  class QueryType < Types::BaseObject
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.


    graphql_name "Query"
   
    field :my_games, Types::RankingType.connection_type do
      description "get games the current user has added"
    end
    def my_games
      context[:current_user].rankings.order("id desc")
    end

    field :game, Types::GameType do
      argument :id, ID, required: true
    end
    def game(id:)
      Game.find(id)
    end

    field :shelf, Types::ShelfType do
      argument :id, ID, required: true
    end
    def shelf(id:)
      Shelf.find(id)
    end


    field :user, Types::UserType do
      argument :id, ID, required: true
    end
    def user(id:)
      User.find(id)
    end


    field :me, Types::UserType
    def me
      context[:current_user]
    end

    field :my_shelves, [Types::ShelfType, null: false], null: false
    def my_shelves
      context[:current_user].shelves
    end
    
    field :comments, Types::CommentType.connection_type do
      argument :resource_type, String, required: true
      argument :resource_id, ID, required: true
    end
    def comments(resource_type:, resource_id:)
      case resource_type
      when "Ranking"
        return Ranking.find(resource_id).comments.order("comments.id")
      else
        raise "unknown type: #{resource_type}"
      end
    end

    field :updates, Types::RankingType.connection_type
    def updates
      context[:current_user].updates
    end

    field :friends, Types::UserType.connection_type
    def friends
      User.where(id: context[:current_user].friend_user_ids).order(:real_name)
    end
    
    field :search, Types::GameType.connection_type do
      argument :query, String, required: true
      argument :autocomplete, Boolean
      description "get games matching the query string"
    end
    def search(query:, autocomplete:, after:)
      page = after && GraphQL::Schema::Base64Encoder.decode(after).to_s || 1
      Search::GameRankrSearch.for(query, page: page)
    end

    #browse section
    field :popular_games, [Types::GameType, null: false], null: false
    def popular_games
      Game.popular
    end

    field :featured_platforms, [Types::PlatformType, null: false], null: false 
    def featured_platforms
      Platform.featured
    end

    field :platforms, Types::PlatformType.connection_type
    def platforms
      Platform.order("name")
    end

    field :recent_reviews, Types::RankingType.connection_type 
    def recent_reviews
      Ranking.recent_reviews
    end
  end
end