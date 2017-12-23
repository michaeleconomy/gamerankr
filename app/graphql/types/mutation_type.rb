Types::MutationType = GraphQL::ObjectType.define do
  name "Mutation"

  field :rank_port, !Types::RankingType do
    argument :port_id, !types.ID
    argument :ranking, types.Int
    argument :remove_ranking, types.Boolean
    argument :review, types.String
    argument :add_shelf_id, types.ID
    argument :remove_shelf_id, types.ID

    resolve ResolverErrorHandler.new ->(obj, args, ctx) do
      user = ctx[:current_user]
      port = Port.find(args[:port_id])
      ranking = user.rankings.where(game_id: port.game_id).first
      if !ranking
        ranking = user.rankings.new
        ranking.game = port.game
      end
      ranking.port = port
      if args[:ranking]
        ranking.ranking = args[:ranking]
      end

      if args[:remove_ranking]
        ranking.ranking = nil
      end

      if args[:review]
        ranking[:review] = args[:review]
      end

      if args[:add_shelf_id]
        ranking.ranking_shelves.find_or_initialize_by(shelf_id: args[:add_shelf_id])
      elsif !ranking.id?
        #TODO - this will break for custom shlelves/localization
        default_shelf = user.shelves.find_by_name("Played")
        if !default_shelf
          raise "no default shelf could be found"
        end
        ranking.ranking_shelves.new(shelf_id: default_shelf.id)
      end
      ranking.save!

      if args[:remove_shelf_id]
        ranking.ranking_shelves.where(shelf_id: args[:remove_shelf_id]).first.destroy
      end

      ranking
    end
  end

  field :destroy_ranking, !Types::RankingType do
    argument :port_id, !types.ID
    resolve ResolverErrorHandler.new ->(obj, args, ctx) do
      ranking = ctx[:current_user].rankings.where(port_id: args[:port_id]).first
      if !ranking
        raise ActiveRecord::RecordNotFound.new("couldn't find ranking for port id #{args[:port_id]}")
      end
      ranking.destroy!
      ranking
    end
  end

  field :comment, !Types::CommentType do
    argument :resource_type, !types.String
    argument :resource_id,  !types.ID
    argument :comment, !types.String

    resolve ResolverErrorHandler.new ->(obj, args, ctx) do
      ctx[:current_user].comments.
        create!(resource_id: resource_id,
          resource_type: resource_type,
          comment: comment)
    end
  end

  field :destroy_comment, !Types::CommentType do
    argument :id, !types.ID
    resolve ResolverErrorHandler.new ->(obj, args, ctx) do
      comment = ctx[:current_user].comments.where(id: args[:id]).first
      if !comment
        raise ActiveRecord::RecordNotFound.new(
          "couldn't find comment for id #{args[:id]} belonging to #{current_user.id}")
      end

      comment.destroy!
      comment
    end
  end
end
