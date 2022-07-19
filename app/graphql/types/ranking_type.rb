module Types
  class RankingType < Types::BaseObject
    graphql_name "Ranking"
    field :id, ID, null: false
    field :game, Types::GameType
    def game
      RecordLoader.for(Game).load(object.game_id)
    end
    
    field :port, Types::PortType
    def port
      RecordLoader.for(Port).load(object.port_id)
    end

    field :user, Types::UserType
    def user
      RecordLoader.for(User).load(object.user_id)
    end

    field :verb, String, null: false
    field :review, String
    field :updated_at, String, null: false, camelize: false
    field :ranking, Int
    field :comments_count, Int, null: false, camelize: false

    field :shelves, [Types::ShelfType, null: false], null: false
    def shelves
      ShelfRecordLoader.for.load(object.id)
    end

    field :url, String, null: false
    def url
      context[:controller].ranking_url(object)
    end
  end
end